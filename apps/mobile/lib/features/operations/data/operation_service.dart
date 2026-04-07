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

  Future<OperationRecord> getOperation(String id) async {
    final res = await _dio.get('/api/operations/$id');
    if (res.statusCode == 200) {
      return OperationRecord.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load operation: ${res.statusCode}');
  }

  Future<OperationRecord> createOperation({
    required String customerId,
    required String deviceId,
    required String title,
    required String description,
    String? internalNote,
    String? technicianId,
    String? technicianName,
    required String priority,
    required String type,
    DateTime? scheduledAtUtc,
  }) async {
    final res = await _dio.post('/api/operations', data: {
      'CustomerId': customerId,
      'DeviceId': deviceId,
      'TechnicianInfo': technicianId == null
          ? null
          : {
              'TechnicianId': technicianId,
              'Name': technicianName ?? '',
            },
      'Title': title,
      'Description': description,
      'InternalNote': internalNote,
      'Priority': priority,
      'Type': type,
      'ScheduledAtUtc': scheduledAtUtc?.toUtc().toIso8601String(),
    }..removeWhere((k, v) => v == null || (v is String && v.isEmpty)));
    if (res.statusCode == 200) {
      return OperationRecord.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create operation: ${res.statusCode}');
  }
}
