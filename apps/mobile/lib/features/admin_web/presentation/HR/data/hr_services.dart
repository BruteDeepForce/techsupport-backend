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

  Future<List<HRLeaveDeductionResponse>> getLeaveDeductions() async {
    final response = await _dio.get('/api/hr/settings/leave-deductions');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => HRLeaveDeductionResponse.fromJson(
              item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to load leave deduction settings: ${response.statusCode}');
  }

  Future<HRLeaveDeductionResponse> createLeaveDeduction(
      HRCreateLeaveDeductionRequest request) async {
    final response = await _dio.post('/api/hr/settings/leave-deductions',
        data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRLeaveDeductionResponse.fromJson(data);
    }
    throw Exception(
        'Failed to create leave deduction setting: ${response.statusCode}');
  }

  Future<HRLeaveDeductionResponse> updateLeaveDeduction(
      String id, HRUpdateLeaveDeductionRequest request) async {
    final response = await _dio.put('/api/hr/settings/leave-deductions/$id',
        data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRLeaveDeductionResponse.fromJson(data);
    }
    throw Exception(
        'Failed to update leave deduction setting: ${response.statusCode}');
  }

  Future<void> deleteLeaveDeduction(String id) async {
    final response = await _dio.delete('/api/hr/settings/leave-deductions/$id');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return;
    }
    throw Exception(
        'Failed to delete leave deduction setting: ${response.statusCode}');
  }

  Future<List<HRDisciplineResponse>> getDisciplines() async {
    final response = await _dio.get('/api/hr/disciplines');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              HRDisciplineResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load disciplines: ${response.statusCode}');
  }

  Future<HRDisciplineResponse> createDiscipline(
      HRCreateDisciplineRequest request) async {
    final response =
        await _dio.post('/api/hr/disciplines', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRDisciplineResponse.fromJson(data);
    }
    throw Exception('Failed to create discipline: ${response.statusCode}');
  }

  Future<HRDisciplineResponse> updateDiscipline(
      String id, HRUpdateDisciplineRequest request) async {
    final response =
        await _dio.put('/api/hr/disciplines/$id', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRDisciplineResponse.fromJson(data);
    }
    throw Exception('Failed to update discipline: ${response.statusCode}');
  }

  Future<List<HRDisciplineEmployeeRecordResponse>> getDisciplineRecords({
    String? employeeId,
    String? disciplineId,
  }) async {
    final response = await _dio.get('/api/hr/disciplines/records',
        queryParameters: {
          if (employeeId != null) 'employeeId': employeeId,
          if (disciplineId != null) 'disciplineId': disciplineId,
        });
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => HRDisciplineEmployeeRecordResponse.fromJson(
              item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to load discipline records: ${response.statusCode}');
  }

  Future<HRDisciplineEmployeeRecordResponse> createDisciplineRecord(
      HRCreateDisciplineEmployeeRecordRequest request) async {
    final response = await _dio.post('/api/hr/disciplines/records',
        data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRDisciplineEmployeeRecordResponse.fromJson(data);
    }
    throw Exception(
        'Failed to create discipline record: ${response.statusCode}');
  }

  Future<HRDisciplineEmployeeRecordResponse> updateDisciplineRecord(
      String id, HRUpdateDisciplineEmployeeRecordRequest request) async {
    final response = await _dio.put('/api/hr/disciplines/records/$id',
        data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRDisciplineEmployeeRecordResponse.fromJson(data);
    }
    throw Exception(
        'Failed to update discipline record: ${response.statusCode}');
  }

  Future<List<HRRewardResponse>> getRewards() async {
    final response = await _dio.get('/api/hr/rewards');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => HRRewardResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load rewards: ${response.statusCode}');
  }

  Future<HRRewardResponse> createReward(HRCreateRewardRequest request) async {
    final response = await _dio.post('/api/hr/rewards', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRRewardResponse.fromJson(data);
    }
    throw Exception('Failed to create reward: ${response.statusCode}');
  }

  Future<HRRewardResponse> updateReward(
      String id, HRUpdateRewardRequest request) async {
    final response =
        await _dio.put('/api/hr/rewards/$id', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRRewardResponse.fromJson(data);
    }
    throw Exception('Failed to update reward: ${response.statusCode}');
  }

  Future<List<HRRewardEmployeeRecordResponse>> getRewardRecords({
    String? employeeId,
    String? rewardId,
  }) async {
    final response = await _dio.get('/api/hr/rewards/records', queryParameters: {
      if (employeeId != null) 'employeeId': employeeId,
      if (rewardId != null) 'rewardId': rewardId,
    });
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => HRRewardEmployeeRecordResponse.fromJson(
              item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load reward records: ${response.statusCode}');
  }

  Future<HRRewardEmployeeRecordResponse> createRewardRecord(
      HRCreateRewardEmployeeRecordRequest request) async {
    final response =
        await _dio.post('/api/hr/rewards/records', data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRRewardEmployeeRecordResponse.fromJson(data);
    }
    throw Exception('Failed to create reward record: ${response.statusCode}');
  }

  Future<HRRewardEmployeeRecordResponse> updateRewardRecord(
      String id, HRUpdateRewardEmployeeRecordRequest request) async {
    final response = await _dio.put('/api/hr/rewards/records/$id',
        data: request.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      return HRRewardEmployeeRecordResponse.fromJson(data);
    }
    throw Exception('Failed to update reward record: ${response.statusCode}');
  }
}
