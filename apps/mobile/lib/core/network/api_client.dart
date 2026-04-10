import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../navigation/app_navigator.dart';
import '../../features/auth/data/token_storage.dart';
import 'auth_interceptor.dart';

/// Singleton ApiClient so the same Dio instance (and interceptors) are
/// shared across the app.
class ApiClient {
  ApiClient._internal() : dio = Dio(_baseOptions()) {
    final tokenStorage = TokenStorage();
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenStorage.getToken,
        clearToken: tokenStorage.clear,
        onUnauthorized: redirectToLogin,
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio dio;

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    );
  }
}
