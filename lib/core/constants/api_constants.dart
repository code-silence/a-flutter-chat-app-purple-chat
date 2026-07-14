import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get imgbbApiKey =>
      dotenv.env['IMGBB_API_KEY'] ?? '';
}