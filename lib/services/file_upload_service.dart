import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FileUploadService {
  static const String cloudName = 'dhcen6mgr';
  static const String uploadPreset = 'smart_tutor_upload';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> pickAndUploadFile({
    required String folderName,
    required List<String> allowedExtensions,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        throw Exception('No file selected');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'smart_tutor/$folderName/${user.uid}'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      final responseText = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseText);
        return data['secure_url'];
      } else {
        throw Exception(responseText);
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}