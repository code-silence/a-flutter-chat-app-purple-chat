import 'package:firebase_database/firebase_database.dart';

import '../../auth/models/user_model.dart';

class SearchRepository {
  final _db = FirebaseDatabase.instance.ref();

  Future<UserModel?> findUser(String username) async {
    final usernameSnap = await _db.child('usernames/$username').get();

    if (!usernameSnap.exists) {
      return null;
    }

    final uid = usernameSnap.value as String;

    final userSnap = await _db.child('users/$uid').get();

    if (!userSnap.exists) {
      return null;
    }

    return UserModel.fromMap(Map<String, dynamic>.from(userSnap.value as Map));
  }

  Future<UserModel?> getUserByUid(String uid) async {
    final snap = await _db.child('users/$uid').get();

    if (!snap.exists) {
      return null;
    }

    return UserModel.fromMap(Map<String, dynamic>.from(snap.value as Map));
  }
}
