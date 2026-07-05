import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../core/models/operation_result.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/utils/validators.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;

  DatabaseReference get usersRef => _database.ref('users');

  DatabaseReference get usernamesRef => _database.ref('usernames');

  Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await usernamesRef.child(username).get();

    return !snapshot.exists;
  }

  Future<OperationResult<UserModel>> register({
    required String username,
    required String displayName,
    required String email,
    required String password,
  }) async {
    username = username.trim().toLowerCase();
    displayName = displayName.trim();
    email = email.trim();

    if (!Validators.isValidUsername(username)) {
      return OperationResult.failure(
        message:
            'Username must be 3-20 characters and contain only lowercase letters, numbers and underscores.',
      );
    }

    if (!Validators.isValidEmail(email)) {
      return OperationResult.failure(message: 'Please enter a valid email.');
    }

    if (!Validators.isValidPassword(password)) {
      return OperationResult.failure(
        message: 'Password must be at least 8 characters.',
      );
    }

    try {
      final available = await isUsernameAvailable(username);

      if (!available) {
        return OperationResult.failure(message: 'Username is already taken.');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return OperationResult.failure(message: 'Failed to create account.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      final user = UserModel(
        uid: firebaseUser.uid,
        username: username,
        displayName: displayName,
        email: email,
        photoUrl: '',
        bio: '',
        isOnline: false,
        lastSeen: now,
        createdAt: now,
      );

      try {
        await usersRef.child(firebaseUser.uid).set(user.toMap());

        await usernamesRef.child(username).set(firebaseUser.uid);

        await firebaseUser.sendEmailVerification();

        return OperationResult.success(
          message: 'Account created. Please verify your email.',
          data: user,
        );
      } catch (e) {
        // Rollback user creation in case of database error
        await firebaseUser.delete();
        return OperationResult.failure(message: 'Failed to save user data.');
      }
    } on FirebaseAuthException catch (e) {
      return OperationResult.failure(message: FirebaseErrorMapper.auth(e));
    } catch (e, stackTrace) {
  debugPrint('Register Error: $e');
  debugPrintStack(stackTrace: stackTrace);

  return OperationResult.failure(
    message: e.toString(),
  );
}
  }
}
