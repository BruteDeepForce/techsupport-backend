import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/technician_models.dart';

class ShiftConflictException implements Exception {
  const ShiftConflictException();

  @override
  String toString() {
    return 'SHIFT_CONFLICT';
  }
}

class AttendanceConflictException implements Exception {
  const AttendanceConflictException();

  @override
  String toString() {
    return 'ATTENDANCE_CONFLICT';
  }
}

class AttendanceNotStartedException implements Exception {
  const AttendanceNotStartedException();

  @override
  String toString() {
    return 'ATTENDANCE_NOT_STARTED';
  }
}

class TechnicianService {
  TechnicianService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<Technician>> listTechnicians() async {
    final res = await _dio.get('/api/technicians');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => Technician.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load technicians: ${res.statusCode}');
  }

  Future<Technician> getTechnician(String id) async {
    final res = await _dio.get('/api/technicians/$id');
    if (res.statusCode == 200) {
      return Technician.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to get technician: ${res.statusCode}');
  }

  Future<TechnicianEmployeeProfile> getEmployeeProfileByClaimUser() async {
    final detailRes = await _dio.get('/api/hr/employees/by-claim-user');
    if (detailRes.statusCode != null &&
        detailRes.statusCode! >= 200 &&
        detailRes.statusCode! < 300) {
      return TechnicianEmployeeProfile.fromJson(
        detailRes.data as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load employee profile detail: ${detailRes.statusCode}',
    );
  }

  Future<String?> createTechnician({
    required String firstName,
    String? lastName,
    required String email,
    String? phoneNumber,
    required String temporaryPassword,
    List<String> expertiseIds = const [],
  }) async {
    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'temporaryPassword': temporaryPassword,
      'ExpertIds': expertiseIds,
    }..removeWhere((k, v) => v == null);

    final res = await _dio.post('/api/technicians', data: body);
    if (res.statusCode == 202 || res.statusCode == 200) {
      // Expecting response like { correlationId: "..", status: "Pending" }
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['correlationId'] != null) {
        return data['correlationId'].toString();
      }
      return null;
    }
    throw Exception('Failed to create technician: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getProvisioningStatus(
      String correlationId) async {
    final res = await _dio.get('/api/technicians/provisioning/$correlationId');
    if (res.statusCode == 200) {
      return (res.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> setActive(String id, bool isActive) async {
    final res = await _dio
        .patch('/api/technicians/$id/active', data: {'isActive': isActive});
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to set active: ${res.statusCode}');
    }
  }

  Future<void> createExpertise(String name) async {
    final res =
        await _dio.post('/api/technicians/createExperts', data: {'Name': name});
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create expertise: ${res.statusCode}');
    }
  }

  Future<List<Experts>> listExpertise() async {
    final res = await _dio.get('/api/technicians/experts');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => Experts.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load expertise: ${res.statusCode}');
  }

  Future<Technician> updateProfile({
    String? firstName,
    String? email,
    String? phoneNumber,
    List<String>? expertIds,
    String? picturePath,
  }) async {
    final formMap = <String, dynamic>{};
    if (firstName != null && firstName.trim().isNotEmpty) {
      formMap['FirstName'] = firstName.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      formMap['Email'] = email.trim();
    }
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      formMap['PhoneNumber'] = phoneNumber.trim();
    }
    if (expertIds != null && expertIds.isNotEmpty) {
      formMap['ExpertIds'] = expertIds;
    }
    if (picturePath != null && picturePath.isNotEmpty) {
      formMap['picture'] = await MultipartFile.fromFile(
        picturePath,
        filename: picturePath.split('/').last,
      );
    }

    final formData = FormData.fromMap(formMap);
    final res =
        await _dio.put('/api/technicians/update-profile', data: formData);
    if (res.statusCode == 200) {
      return Technician.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to update technician profile: ${res.statusCode}');
  }

  Future<List<ShiftTemplateModel>> listShiftTemplates({
    String branchId = '00000000-0000-0000-0000-000000000000',
    bool includeInactive = false,
  }) async {
    final res = await _dio.get(
      '/api/hr/shifts/templates',
      queryParameters: {
        'branchId': branchId,
        'includeInactive': includeInactive,
      },
    );
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => ShiftTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load shift templates: ${res.statusCode}');
  }

  Future<ShiftTemplateModel> createShiftTemplate(
      CreateShiftTemplatePayload payload) async {
    final res = await _dio.post(
      '/api/hr/shifts/templates',
      data: payload.toJson(),
    );
    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      return ShiftTemplateModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create shift template: ${res.statusCode}');
  }

  Future<List<ShiftAssignmentModel>> listShiftAssignments({
    String branchId = '00000000-0000-0000-0000-000000000000',
    DateTime? date,
  }) async {
    final res = await _dio.get(
      '/api/hr/shifts/assignments',
      queryParameters: {
        'branchId': branchId,
        if (date != null) 'date': date.toUtc().toIso8601String(),
      },
    );
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => ShiftAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load shift assignments: ${res.statusCode}');
  }

  Future<ShiftAssignmentModel> createShiftAssignment(
      CreateShiftAssignmentPayload payload) async {
    try {
      final res = await _dio.post(
        '/api/hr/shifts/assignments',
        data: payload.toJson(),
      );
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return ShiftAssignmentModel.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        throw const ShiftConflictException();
      }
      rethrow;
    }
    throw Exception('Failed to create shift assignment:');
  }

  Future<List<BlockShiftAssignmentResponse>> createBlockShiftAssignments(
      CreateBlockShiftAssignmentPayload payload) async {
    final res = await _dio.post(
      '/api/hr/shifts/assignments/block-insert',
      data: payload.toJson(),
    );
    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) =>
              BlockShiftAssignmentResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to create block shift assignments: ${res.statusCode}');
  }

  Future<List<ShiftAssignmentModel>> getMyShiftAssignments() async {
    final res = await _dio.get('/api/hr/attendance/getmy-shifts');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => ShiftAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load my shifts: ${res.statusCode}');
  }

  Future<void> checkIn(CreateAttendanceCheckInPayload payload) async {
    try {
      final res = await _dio.post(
        '/api/hr/attendance/check-in',
        data: payload.toJson(),
      );
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        throw const AttendanceConflictException();
      }
      rethrow;
    }
    throw Exception('Failed to check in.');
  }

  Future<void> checkOut(
    CreateAttendanceCheckOutPayload payload,
  ) async {
    try {
      final res = await _dio.post(
        '/api/hr/attendance/check-out',
        data: payload.toJson(),
      );
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        throw const AttendanceConflictException();
      }
      if (e is DioException && e.response?.statusCode == 404) {
        throw const AttendanceNotStartedException();
      }
      rethrow;
    }
    throw Exception('Failed to check out.');
  }
}
