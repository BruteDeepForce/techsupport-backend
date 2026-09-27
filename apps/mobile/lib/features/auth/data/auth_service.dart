import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  /// Calls POST /api/identity/account/login with { email, password }
  /// Returns token string on success.
  Future<String> login(String email, String password) async {
    final res = await _dio.post('/api/identity/account/login',
        data: {'Email': email, 'Password': password});
    if (res.statusCode == 200) {
      final token = res.data['token'] as String?;
      if (token != null) return token;
      throw Exception('No token in response');
    }
    throw Exception('Login failed: ${res.statusCode}');
  }

  Future<String> register(
      String email, String password, String role, String tenantName,
      {String? branchId}) async {
    // Backend RegisterDto now expects: Email, Password, Role, tenantName, BranchId
    final data = {
      'Email': email,
      'Password': password,
      'Role': role,
      'tenantName': tenantName,
      'BranchId': branchId,
    };
    final res = await _dio.post('/api/identity/account/register', data: data);
    if (res.statusCode == 200) {
      final token = res.data['token'] as String?;
      if (token != null) return token;
      throw Exception('No token in response');
    }
    throw Exception('Register failed: ${res.statusCode}');
  }

  Future<void> requestPasswordResetCode(String email) async {
    await _dio.post(
      '/api/identity/account/forgot-password',
      data: {'email': email},
    );
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      '/api/identity/account/reset-password',
      data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
    );

    final token = response.data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('No token in password reset response');
    }

    return token;
  }
}
