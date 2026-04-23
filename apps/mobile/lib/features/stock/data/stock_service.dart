import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/stock_models.dart';

class StockService {
  StockService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<StockCategory>> listCategories() async {
    final res = await _dio.get('/api/stock/categories');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => StockCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load categories: ${res.statusCode}');
  }

  Future<String?> createCategory({required String name}) async {
    final res = await _dio.post('/api/stock/categories', data: {
      'branchId': null,
      'name': name,
    });
    if (res.statusCode == 200) {
      return (res.data['id'] ?? res.data['Id'])?.toString();
    }
    return null;
  }

  Future<List<StockItem>> listItems() async {
    final res = await _dio.get('/api/stock/items');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => StockItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load items: ${res.statusCode}');
  }

  Future<List<StockItem>> listItemsByCategory(String categoryId) async {
    final res = await _dio.get('/api/stock/items/category/$categoryId');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => StockItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load items: ${res.statusCode}');
  }

  Future<String?> createItem({
    required String categoryId,
    required String sku,
    required String barcode,
    required String name,
    String? description,
    String? unit,
    double? unitPrice,
    required int initialQuantity,
  }) async {
    final res = await _dio.post('/api/stock/items', data: {
      'branchId': null,
      'categoryId': categoryId,
      'sku': sku,
      'barcode': barcode,
      'name': name,
      'description': description,
      'unit': unit,
      'unitPrice': unitPrice,
      'initialQuantity': initialQuantity,
    });
    if (res.statusCode == 200) {
      return (res.data['id'] ?? res.data['Id'])?.toString();
    }
    return null;
  }

  Future<void> reserveStock({
    required String stockItemId,
    required String operationId,
    required int quantity,
  }) async {
    final res = await _dio.post('/api/stock/reservations', data: {
      'stockItemId': stockItemId,
      'operationId': operationId,
      'quantity': quantity,
      'branchId': null,
    });
    if (res.statusCode != 200) {
      throw Exception('Failed to reserve stock: ${res.statusCode}');
    }
  }

  Future<void> publishOffer(String operationId, double laborAmount) async {
    final res = await _dio.post('/api/stock/reservations/publish-offer',
        data: {'operationId': operationId, 'LaborAmount': laborAmount});
    if (res.statusCode != 200) {
      throw Exception('Failed to publish offer: ${res.statusCode}');
    }
  }
}
