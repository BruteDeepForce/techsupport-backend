import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class QuickSaleProduct {
  const QuickSaleProduct({required this.id, required this.name, required this.sku, required this.unitPrice, required this.quantityAvailable, this.barcode});
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final double unitPrice;
  final int quantityAvailable;

  factory QuickSaleProduct.fromJson(Map<String, dynamic> json) => QuickSaleProduct(
        id: json['id'].toString(), name: json['name']?.toString() ?? '', sku: json['sku']?.toString() ?? '',
        barcode: json['barcode']?.toString(), unitPrice: (json['unitPrice'] as num).toDouble(),
        quantityAvailable: (json['quantityAvailable'] as num).toInt(),
      );
}

class QuickSaleService {
  QuickSaleService({Dio? dio}) : _dio = dio ?? ApiClient().dio;
  final Dio _dio;

  Future<List<QuickSaleProduct>> products({String? search}) async {
    final response = await _dio.get('/api/trade/quick-sales/products', queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(), 'pageSize': 100,
    });
    final body = Map<String, dynamic>.from(response.data as Map);
    return (body['items'] as List).map((item) => QuickSaleProduct.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Map<String, dynamic>> create(Map<String, int> quantities, {String paymentMethod = 'Cash'}) async {
    final key = 'mobile-${DateTime.now().microsecondsSinceEpoch}';
    final response = await _dio.post('/api/trade/quick-sales', data: {
      'idempotencyKey': key,
      'paymentMethod': paymentMethod,
      'discountAmount': 0,
      'paidAmount': null,
      'items': quantities.entries.map((entry) => {'stockItemId': entry.key, 'quantity': entry.value}).toList(),
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
