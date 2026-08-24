import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionHelper {
  ImageCompressionHelper._();

  static Future<Uint8List> compressLogo(
      Uint8List bytes,
      ) async {
    Uint8List current = bytes;

    int quality = 85;

    while (current.length > 200 * 1024 &&
        quality >= 30) {
      final result =
      await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: quality,
        format: CompressFormat.webp,
      );

      current = Uint8List.fromList(result);

      quality -= 10;
    }

    return current;
  }
}