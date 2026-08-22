import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> downloadQr(
    List<int> bytes,
    String fileName,
    ) async {
  final data = Uint8List.fromList(bytes);

  final blob = web.Blob(
    [data.buffer.toJS].toJS,
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