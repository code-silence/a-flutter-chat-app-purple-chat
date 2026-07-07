import '../../auth/models/user_model.dart';
import '../repository/search_repository.dart';

class SearchController {
  final SearchRepository _repository;

  SearchController(this._repository);

  Future<UserModel?> findUser(String username) {
    return _repository.findUser(
      username.trim().toLowerCase(),
    );
  }
}