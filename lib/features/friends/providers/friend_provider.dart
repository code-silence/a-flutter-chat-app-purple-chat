import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/friend_repository.dart';

final friendRepositoryProvider =
    Provider((ref) => FriendRepository());