import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  final Dio dio;
}
