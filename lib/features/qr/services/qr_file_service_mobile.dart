import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrFileService {
  static Future<void> downloadQr(
      Uint8List bytes,
      String fileName,
      ) async {
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

  static Future<void> shareQr(
      Uint8List bytes,
      String fileName,
      ) async {
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
        files: [
          XFile(file.path),
        ],
        text: 'ScanAura Digital QR',
      ),
    );
  }
}