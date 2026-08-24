import 'dart:typed_data';

Future<void> downloadQrPack(
    Uint8List bytes,
    String fileName,
    ) async {
  throw UnsupportedError(
    'QR pack download is not supported on this platform.',
  );
}