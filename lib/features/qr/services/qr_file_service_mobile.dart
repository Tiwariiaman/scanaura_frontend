import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrFileService {
  static Future<void> downloadQr(
      Uint8List bytes,
      String fileName,
      ) async {
    await downloadFile(
      bytes,
      fileName,
      mimeType: 'image/png',
    );
  }

  static Future<void> downloadFile(
      Uint8List bytes,
      String fileName, {
        String mimeType = 'application/octet-stream',
      }) async {
    final directory =
    await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/$fileName',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
  }

  static Future<void> shareQr({
    required Uint8List bytes,
    required String fileName,
    required String text,
    String? subject,
  }) async {
    final directory =
    await getTemporaryDirectory();

    final file = File(
      '${directory.path}/$fileName',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        files: [
          XFile(
            file.path,
            mimeType: 'image/png',
          ),
        ],
      ),
    );
  }
}