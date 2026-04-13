import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Simple interceptor that adds Authorization: Bearer <token> header when
/// a token is available via the provided tokenProvider.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Future<String?> Function() tokenProvider,
    required Future<void> Function() clearToken,
    required VoidCallback onUnauthorized,
  })  : _tokenProvider = tokenProvider,
        _clearToken = clearToken,
        _onUnauthorized = onUnauthorized;

  final Future<String?> Function() _tokenProvider;
  final Future<void> Function() _clearToken;
  final VoidCallback _onUnauthorized;
  bool _isHandlingUnauthorized = false;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // ignore token provider errors here; requests proceed without auth header
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 && !_isHandlingUnauthorized) {
      _isHandlingUnauthorized = true;
      try {
        await _clearToken();
      } catch (_) {
        // ignore
      }
      _onUnauthorized();
      _isHandlingUnauthorized = false;
    }
    super.onError(err, handler);
  }
}
