import 'dart:typed_data';
import 'dart:html' as html;

bool openPdfInNewTab(Uint8List bytes, {String fileName = 'invoice.pdf'}) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');

  // Delay revoke so browser can finish opening the resource.
  Future<void>.delayed(const Duration(seconds: 30), () {
    html.Url.revokeObjectUrl(url);
  });

  return true;
}
