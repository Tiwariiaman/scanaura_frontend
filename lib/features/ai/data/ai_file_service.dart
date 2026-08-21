import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AiSelectedFile {
  const AiSelectedFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.isPdf,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final bool isPdf;
}

class AiFileService {
  AiFileService({
    ImagePicker? imagePicker,
  }) : _imagePicker =
      imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<AiSelectedFile?> pickFromCamera() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception(
        'Captured image is empty.',
      );
    }

    return AiSelectedFile(
      bytes: bytes,
      fileName: file.name.isNotEmpty
          ? file.name
          : 'menu_camera.jpg',
      mimeType: 'image/jpeg',
      isPdf: false,
    );
  }

  Future<AiSelectedFile?> pickFromGalleryOrFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'pdf',
      ],
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw Exception(
        'Unable to read the selected file.',
      );
    }

    final extension =
        file.extension?.toLowerCase() ?? '';

    return AiSelectedFile(
      bytes: bytes,
      fileName: file.name,
      mimeType: _mimeType(extension),
      isPdf: extension == 'pdf',
    );
  }

  String _mimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'pdf':
        return 'application/pdf';

      default:
        throw Exception(
          'Unsupported file type.',
        );
    }
  }
}