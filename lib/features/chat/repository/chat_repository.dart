import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/utils/chat_utils.dart';
import '../models/message_model.dart';

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
  }
}
