import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/imgbb_service.dart';

final imgbbServiceProvider = Provider<ImgBBService>((ref) {
  return ImgBBService();
});