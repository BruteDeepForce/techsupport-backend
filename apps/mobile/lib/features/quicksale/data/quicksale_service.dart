import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/quicksale_models.dart';

class QuickSaleService {
  QuickSaleService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<QuickSaleStockItem>> getStockItems() async {
    final res = await _dio.get('/api/stock/items');
    return (res.data as List)
        .map((e) => QuickSaleStockItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<QuickSaleSummary>> getQuickSales() async {
    final res = await _dio.get('/api/trade/quick-sales');
    return (res.data as List)
        .map((e) => QuickSaleSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createQuickSale({
    required List<QuickSaleCartLine> lines,
    required double discountAmount,
    required double paidAmount,
    required String paymentMethod,
    String currency = 'TRY',
    String? note,
  }) async {
    await _dio.post('/api/trade/quick-sales', data: {
      'lines': lines
          .map((line) => {
                'stockItemId': line.item.id,
                'quantity': line.quantity,
                'unitPriceOverride': line.unitPrice,
              })
          .toList(),
      'discountAmount': discountAmount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'note': note,
    });
  }
}
