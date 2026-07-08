import 'package:firebase_database/firebase_database.dart';

import '../../auth/models/user_model.dart';
import 'package:flutter/foundation.dart';

class SearchRepository {
  final _db = FirebaseDatabase.instance.ref();

  Future<UserModel?> findUser(String username) async {
    debugPrint('Searching: $username');
    final usernameSnap = await _db.child('usernames/$username').get();
    debugPrint('Username exists: ${usernameSnap.exists}');

    if (!usernameSnap.exists) {
      debugPrint('Username not found: $username');
      return null;
    }

    final uid = usernameSnap.value as String;

    final userSnap = await _db.child('users/$uid').get();
    debugPrint('User exists: ${userSnap.exists}');
debugPrint(userSnap.value.toString());

    if (!userSnap.exists) {
      return null;
    }

    return UserModel.fromMap(Map<String, dynamic>.from(userSnap.value as Map));
  }

  Future<UserModel?> getUserByUid(String uid) async {
    final snap = await _db.child('users/$uid').get();
    debugPrint('Getting user by UID: $uid');
    debugPrint('User exists: ${snap.exists}');
    debugPrint(snap.value.toString());

    if (!snap.exists) {
      return null;
    }

    return UserModel.fromMap(Map<String, dynamic>.from(snap.value as Map));
  }
}
