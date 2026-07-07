import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/presence_repository.dart';

final presenceRepositoryProvider =
    Provider((ref) => PresenceRepository());