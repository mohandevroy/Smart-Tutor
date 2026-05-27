import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> pickAndUploadFile({
    required String folderName,
    required List<String> allowedExtensions,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      final ref = _storage
          .ref()
          .child(folderName)
          .child(user.uid)
          .child(fileName);

      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}