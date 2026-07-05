import '../repository/auth_repository.dart';
import '../../../core/models/operation_result.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthRepository repository;

  AuthController(this.repository);

  bool isLoggedIn() {
    return repository.currentUser != null;
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
