import 'dart:html' as html;
import 'dart:typed_data';

class QrFileService {
  static Future<void> downloadQr(
      Uint8List bytes,
      String fileName,
      ) async {
    final blob = html.Blob(
      [bytes],
      'image/png',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(
      href: url,
    )
      ..setAttribute(
        'download',
        fileName,
      )
      ..style.display = 'none';

    html.document.body?.children.add(anchor);

    anchor.click();

    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  static Future<void> shareQr(
      Uint8List bytes,
      String fileName,
      ) async {
    // Browser file sharing is not available
    // consistently across all browsers.
    //
    // Therefore we provide a reliable browser
    // download as the fallback.

    await downloadQr(
      bytes,
      fileName,
    );
  }
}