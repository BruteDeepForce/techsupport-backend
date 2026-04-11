import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/technician_models.dart';

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
}
