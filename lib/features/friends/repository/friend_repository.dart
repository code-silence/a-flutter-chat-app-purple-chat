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
