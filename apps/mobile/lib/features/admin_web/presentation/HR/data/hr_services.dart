import 'package:dio/dio.dart';
import '/core/network/api_client.dart';
import '../model/hr_models.dart';

class HRService {
  HRService({Dio? dio}) : _dio = dio ?? ApiClient().dio;
  final Dio _dio;

  Future<HREmployeeLargeDetailResponse> getLargeDetailEmployees(
      {String? branchId}) async {
    final response = await _dio.get('/api/hr/employees', queryParameters: {
      if (branchId != null) 'branchId': branchId,
    });
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return HREmployeeLargeDetailResponse.fromJson(data);
    }
    throw Exception('Failed to load employees: ${response.statusCode}');
  }

  Future<HREmployeeDetailResponse> getEmployeeById(String employeeId) async {
    final response = await _dio.get('/api/hr/employees/$employeeId');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HREmployeeDetailResponse.fromJson(data);
    }
    throw Exception('Failed to load employee detail: ${response.statusCode}');
  }

  Future<HRLargeLeaveResponseList> getLeaves(
      {String? branchId, String? startDate, String? endDate}) async {
    final response = await _dio.get('/api/hr/leaves', queryParameters: {
      if (branchId != null) 'branchId': branchId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return HRLargeLeaveResponseList.fromJson(data);
    }
    throw Exception('Failed to load leaves: ${response.statusCode}');
  }

  Future<String> createLeave(HRLeaveCreateRequest request) async {
    final response = await _dio.post('/api/hr/leaves', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return data['id'] as String;
    }
    final data = response.data;
    return data != null &&
            data is Map<String, dynamic> &&
            data['message'] != null
        ? data['message'] as String
        : 'Failed to create leave: ${response.statusCode}';
  }

  Future<String> decideLeave(String leaveId, String status) async {
    final response = await _dio.post('/api/hr/leaves/decision',
        data: HRLeaveDecideRequest(leaveId: leaveId, status: status).toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Leave decision successful';
    }
    final data = response.data;
    return data != null &&
            data is Map<String, dynamic> &&
            data['message'] != null
        ? data['message'] as String
        : 'Failed to decide leave: ${response.statusCode}';
  }

  Future<List<HRPositionResponse>> getPositions() async {
    final response = await _dio.get('/api/hr/positions');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              HRPositionResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load positions: ${response.statusCode}');
  }

  Future<HRPositionResponse> createPosition(HRCreatePositionRequest request) async {
    final response = await _dio.post('/api/hr/positions', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRPositionResponse.fromJson(data);
    }
    throw Exception('Failed to create position: ${response.statusCode}');
  }
}
