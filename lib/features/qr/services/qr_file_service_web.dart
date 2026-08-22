import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class QrFileService {
  static Future<void> downloadQr(
      Uint8List bytes,
      String fileName,
      ) async {
    final blob = web.Blob(
      [bytes.buffer.toJS].toJS,
      web.BlobPropertyBag(
        type: 'image/png',
      ),
    );

    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);

    anchor.click();

    anchor.remove();

    web.URL.revokeObjectURL(url);
  }

  static Future<void> shareQr(
      Uint8List bytes,
      String fileName,
      ) async {
    // Browser sharing is not consistently available
    // across all browsers, so download is used as
    // the reliable web fallback.

    await downloadQr(
      bytes,
      fileName,
    );
  }
}