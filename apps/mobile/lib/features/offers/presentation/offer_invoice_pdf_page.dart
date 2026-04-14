import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OfferInvoicePdfPage extends StatelessWidget {
  const OfferInvoicePdfPage({
    super.key,
    required this.offerId,
    required this.pdfBytes,
  });

  final String offerId;
  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teklif Faturası ${_shortId(offerId)}')),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
