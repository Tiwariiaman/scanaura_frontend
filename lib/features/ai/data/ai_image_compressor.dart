import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class AiImageCompressor {
  const AiImageCompressor();

  Future<Uint8List> compress({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw Exception(
        'Image is empty.',
      );
    }

    final result =
    await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1600,
      minHeight: 1600,
      quality: 80,
      format: _getFormat(fileName),
    );

    if (result.isEmpty) {
      throw Exception(
        'Unable to process the selected image.',
      );
    }

    return Uint8List.fromList(result);
  }

  CompressFormat _getFormat(
      String fileName,
      ) {
    final extension =
    fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
        return CompressFormat.png;

      case 'webp':
        return CompressFormat.webp;

      case 'jpg':
      case 'jpeg':
      default:
        return CompressFormat.jpeg;
    }
  }
}