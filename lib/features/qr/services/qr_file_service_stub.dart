import 'dart:typed_data';

class QrFileService {
  static Future<void> downloadQr(
      Uint8List bytes,
      String fileName,
      ) async {
    throw UnsupportedError(
      'QR download is not supported on this platform.',
    );
  }

  static Future<void> downloadFile(
      Uint8List bytes,
      String fileName, {
        String mimeType = 'application/octet-stream',
      }) async {
    throw UnsupportedError(
      'File download is not supported on this platform.',
    );
  }

  static Future<void> shareQr({
    required Uint8List bytes,
    required String fileName,
    required String text,
    String? subject,
  }) async {
    throw UnsupportedError(
      'QR sharing is not supported on this platform.',
    );
  }
}