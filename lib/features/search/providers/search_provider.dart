import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/search_controller.dart';
import '../repository/search_repository.dart';

final searchRepositoryProvider =
    Provider((ref) => SearchRepository());

final searchControllerProvider =
    Provider(
      (ref) => SearchController(
        ref.read(searchRepositoryProvider),
      ),
    );