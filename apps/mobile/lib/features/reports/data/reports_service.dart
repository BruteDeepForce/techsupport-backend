import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

import '../models/report_models.dart';

class ReportsService {
  ReportsService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<PagedResult<ReportSummary>> listReports(
      {int page = 1, int pageSize = 20}) async {
    final res = await _dio.get('/api/reports',
        queryParameters: {'page': page, 'pageSize': pageSize});
    if (res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>;
      return PagedResult<ReportSummary>.fromJson(
          data, (item) => ReportSummary.fromJson(item as Map<String, dynamic>));
    }
    throw Exception('Failed to load reports: ${res.statusCode}');
  }

  Future<List<ReportMetric>> getMetrics() async {
    final res = await _dio.get('/api/reports/metrics');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => ReportMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load metrics: ${res.statusCode}');
  }

  Future<List<TechnicianSummary>> getTechnicianSummaries() async {
    final res = await _dio.get('/api/reports/technicians/summary');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => TechnicianSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load technician summaries: ${res.statusCode}');
  }
}
