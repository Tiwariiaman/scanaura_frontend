import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

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
    final blob = web.Blob(
      [bytes.buffer.toJS].toJS,
      web.BlobPropertyBag(
        type: mimeType,
      ),
    );

    final url =
    web.URL.createObjectURL(blob);

    final anchor =
    web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);

    anchor.click();

    anchor.remove();

    web.URL.revokeObjectURL(url);
  }

  static Future<void> shareQr({
    required Uint8List bytes,
    required String fileName,
    required String text,
    String? subject,
  }) async {
    final file = web.File(
      [bytes.buffer.toJS].toJS,
      fileName,
      web.FilePropertyBag(
        type: 'image/png',
      ),
    );

    final shareData = web.ShareData(
      title: subject ?? 'ScanAura',
      text: text,
      files: [file].toJS,
    );

    final navigator =
        web.window.navigator;

    try {
      if (navigator.canShare(shareData)) {
        await navigator
            .share(shareData)
            .toDart;
        return;
      }
    } catch (_) {
      // Continue to text-only share.
    }

    try {
      final textOnly =
      web.ShareData(
        title:
        subject ?? 'ScanAura',
        text: text,
      );

      await navigator
          .share(textOnly)
          .toDart;

      return;
    } catch (_) {
      // Final fallback.
      await downloadQr(
        bytes,
        fileName,
      );
    }
  }
}