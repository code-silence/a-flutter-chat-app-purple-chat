import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/utils/chat_utils.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../../auth/models/user_model.dart';

class ChatRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<MessageModel>> messageStream(String friendUid) {
    final me = _auth.currentUser;
    if (me == null) {
      return const Stream.empty();
    }

    final chatId = ChatUtils.getChatId(me.uid, friendUid);

    return _db.child('messages/$chatId').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <MessageModel>[];
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      final messages = data.entries.map((entry) {
        return MessageModel.fromMap(
          entry.key,
          Map<dynamic, dynamic>.from(entry.value),
        );
      }).toList();

      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      return messages;
    });
  }

  Future<void> sendMessage({
    required String friendUid,
    required String text,
  }) async {
    final me = _auth.currentUser;
    if (me == null) return;

    final chatId = ChatUtils.getChatId(me.uid, friendUid);

    final messageRef = _db.child('messages/$chatId').push();

    await messageRef.set({
      'senderUid': me.uid,
      'text': text.trim(),
      'sentAt': ServerValue.timestamp,
      'deliveredAt': 0,
      'readAt': 0,
    });

    final unreadRef = _db.child('chat_meta/$friendUid/${me.uid}/unread');

    final snap = await unreadRef.get();

    final current = (snap.value as int?) ?? 0;

    await unreadRef.set(current + 1);

    await _db.child('chats/$chatId').set({
      'members': {me.uid: true, friendUid: true},
      'lastMessage': text.trim(),
      'lastMessageTime': ServerValue.timestamp,
      'lastSenderUid': me.uid,
    });
  }

  Future<void> markMessagesAsRead(String friendUid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    final chatId = ChatUtils.getChatId(me.uid, friendUid);

    final snap = await _db.child('messages/$chatId').get();

    if (!snap.exists) return;

    final data = Map<dynamic, dynamic>.from(snap.value as Map);

    for (final entry in data.entries) {
      final messageId = entry.key;
      final message = Map<dynamic, dynamic>.from(entry.value);

      if (message['senderUid'] == friendUid && (message['readAt'] ?? 0) == 0) {
        await _db
            .child('messages/$chatId/$messageId/readAt')
            .set(ServerValue.timestamp);
      }

      if (message['senderUid'] == friendUid &&
          (message['deliveredAt'] ?? 0) == 0) {
        await _db
            .child('messages/$chatId/$messageId/deliveredAt')
            .set(ServerValue.timestamp);
      }
    }

    await _db.child('chat_meta/${me.uid}/$friendUid/unread').set(0);
  }

  Stream<List<ChatModel>> chatStream() {
    final me = _auth.currentUser;
    if (me == null) {
      return const Stream.empty();
    }

    return _db.child('chats').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <ChatModel>[];
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      final chats = <ChatModel>[];

      for (final entry in data.entries) {
        final chat = ChatModel.fromMap(
          entry.key,
          Map<dynamic, dynamic>.from(entry.value),
        );

        if (chat.members.containsKey(me.uid)) {
          chats.add(chat);
        }
      }

      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return chats;
    });
  }

  Future<UserModel?> getFriend(ChatModel chat) async {
    final me = _auth.currentUser;
    if (me == null) return null;

    final friendUid = chat.members.keys.firstWhere((uid) => uid != me.uid);

    final snap = await _db.child('users/$friendUid').get();

    if (!snap.exists) return null;

    return UserModel.fromMap(Map<String, dynamic>.from(snap.value as Map));
  }

  Stream<int> unreadCount(String friendUid) {
    final me = _auth.currentUser;
    if (me == null) {
      return const Stream.empty();
    }

    return _db.child('chat_meta/${me.uid}/$friendUid/unread').onValue.map((
      event,
    ) {
      return (event.snapshot.value as int?) ?? 0;
    });
  }
}
