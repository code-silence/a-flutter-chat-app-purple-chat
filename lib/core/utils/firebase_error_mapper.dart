import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String auth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email is already in use.';

      case 'invalid-email':
        return 'Invalid email address.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'user-not-found':
        return 'User not found.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      case 'network-request-failed':
        return 'No internet connection.';

      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}