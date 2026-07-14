import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ImgBBService {
  Future<Map<String, dynamic>> upload(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.imgbb.com/1/upload?key=${ApiConstants.imgbbApiKey}',
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    final json = jsonDecode(body);

    return {
      'photoUrl': json['data']['url'],
      'deleteUrl': json['data']['delete_url'],
    };
  }
}