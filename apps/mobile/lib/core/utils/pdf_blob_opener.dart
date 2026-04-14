import 'dart:typed_data';

import 'pdf_blob_opener_stub.dart'
    if (dart.library.html) 'pdf_blob_opener_web.dart' as impl;

bool openPdfInNewTab(Uint8List bytes, {String fileName = 'invoice.pdf'}) {
  return impl.openPdfInNewTab(bytes, fileName: fileName);
}
