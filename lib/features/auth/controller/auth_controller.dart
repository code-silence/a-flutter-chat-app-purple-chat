import '../repository/auth_repository.dart';
import '../../../core/models/operation_result.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthRepository repository;

  AuthController(this.repository);

  bool isLoggedIn() {
    return repository.currentUser != null;
  }

  Future<bool> shouldGoToHome() async {
    final user = repository.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return user.emailVerified;
  }

  Future<bool> isEmailVerified() {
    return repository.isEmailVerified();
  }

  Future<void> resendVerificationEmail() {
    return repository.resendVerificationEmail();
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<OperationResult<void>> login({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }

  Future<OperationResult<void>> sendPasswordResetEmail({
  required String email,
}) {
  return repository.sendPasswordResetEmail(
    email: email,
  );
}

  Future<OperationResult<UserModel>> register({
    required String username,
    required String displayName,
    required String email,
    required String password,
  }) {
    return repository.register(
      username: username,
      displayName: displayName,
      email: email,
      password: password,
    );
  }
}
