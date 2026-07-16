import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String auth(FirebaseAuthException e) {
    switch (e.code) {
      case 'missing-email':
        return 'Please enter your email address.';

      case 'missing-password':
        return 'Please enter your password.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password must be at least 6 characters long.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';

      case 'network-request-failed':
        return 'No internet connection.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
