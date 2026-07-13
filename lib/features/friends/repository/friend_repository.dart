import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/friend_request.dart';
import '../../auth/models/user_model.dart';
import '../../search/repository/search_repository.dart';

class FriendRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();
  final _searchRepository = SearchRepository();

  Future<void> sendRequest(String receiverUid) async {
    final sender = _auth.currentUser;
    if (sender == null) return;
    if (await isBlocked(receiverUid)) {
      return;
    }
    if (sender.uid == receiverUid) {
      return;
    }

    await _db.child('friend_requests/$receiverUid/${sender.uid}').set({
      'sentAt': ServerValue.timestamp,
      'status': 'pending',
    });
  }

  Stream<List<FriendRequest>> getRequests() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db.child('friend_requests/${user.uid}').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <FriendRequest>[];
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      return data.entries.map((entry) {
        return FriendRequest.fromMap(
          entry.key,
          Map<dynamic, dynamic>.from(entry.value),
        );
      }).toList();
    });
  }

  Future<void> acceptRequest(String senderUid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    await _db.child('friends/${me.uid}/$senderUid').set(true);

    await _db.child('friends/$senderUid/${me.uid}').set(true);

    await _db.child('friend_requests/${me.uid}/$senderUid').remove();
  }

  Future<void> rejectRequest(String senderUid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    await _db.child('friend_requests/${me.uid}/$senderUid').remove();
  }

  Future<UserModel?> getUser(String uid) {
    return _searchRepository.getUserByUid(uid);
  }

  Future<void> removeFriend(String friendUid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    await _db.child('friends/${me.uid}/$friendUid').remove();
    await _db.child('friends/$friendUid/${me.uid}').remove();
  }

  Future<void> blockUser(String uid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    await removeFriend(uid);

    await _db.child('blocked_users/${me.uid}/$uid').set(true);
  }

  Future<bool> isBlocked(String uid) async {
    final me = _auth.currentUser;
    if (me == null) return true;

    final iBlocked = await _db.child('blocked_users/${me.uid}/$uid').get();

    final blockedMe = await _db.child('blocked_users/$uid/${me.uid}').get();

    return iBlocked.exists || blockedMe.exists;
  }

  Stream<List<String>> blockedUsersStream() {
    final me = _auth.currentUser;
    if (me == null) {
      return const Stream.empty();
    }

    return _db.child('blocked_users/${me.uid}').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <String>[];
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      return data.keys.map((e) => e.toString()).toList();
    });
  }


  Future<void> unblockUser(String uid) async {
    final me = _auth.currentUser;
    if (me == null) return;

    await _db.child('blocked_users/${me.uid}/$uid').remove();
  }

  Stream<List<String>> getFriends() {
    final me = _auth.currentUser;
    if (me == null) {
      return const Stream.empty();
    }

    return _db.child('friends/${me.uid}').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <String>[];
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      return data.keys.map((e) => e.toString()).toList();
    });
  }
}
