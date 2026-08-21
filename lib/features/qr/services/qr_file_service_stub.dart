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

  static Future<void> shareQr(
      Uint8List bytes,
      String fileName,
      ) async {
    throw UnsupportedError(
      'QR sharing is not supported on this platform.',
    );
  }
}