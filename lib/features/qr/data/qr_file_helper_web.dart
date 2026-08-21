import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadQr(
    List<int> bytes,
    String fileName,
    ) async {
  final blob = html.Blob(
    [
      Uint8List.fromList(bytes),
    ],
    'image/png',
  );

  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.children.add(anchor);

  anchor.click();

  anchor.remove();

  html.Url.revokeObjectUrl(url);
}