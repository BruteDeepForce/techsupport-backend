import 'package:dio/dio.dart';

/// Simple interceptor that adds Authorization: Bearer <token> header when
/// a token is available via the provided tokenProvider.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final Future<String?> Function() _tokenProvider;

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
}
