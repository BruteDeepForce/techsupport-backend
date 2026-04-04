import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/operation_models.dart';

class OperationService {
  OperationService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<OperationRecord>> listOperations() async {
    final res = await _dio.get('/api/operations/Get-all');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => OperationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load operations: ${res.statusCode}');
  }
}
