import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

/// AI kernel sohbet servisidir.
///
/// ConversationId frontend tarafında üretilir ve sayfa kapanana kadar
/// her istekte aynı değerle gönderilir; backend bu id ile konuşma
/// geçmişini tutar.
class AiChatService {
  AiChatService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<String> sendMessage({
    required String conversationId,
    required String input,
  }) async {
    final response = await _dio.post<String>(
      '/api/ai/Chat-Kernel',
      data: {
        'conversationId': conversationId,
        'input': input,
      },
      options: Options(
        // Kernel + tool çağrıları varsayılan 15 sn'yi aşabiliyor.
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.plain,
      ),
    );

    final data = response.data;
    if (data == null || data.trim().isEmpty) {
      throw const AiChatException('Asistan boş yanıt döndü.');
    }
    return data.trim();
  }
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}