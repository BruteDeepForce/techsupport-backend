import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../model/trade_models.dart';
import 'realtime_trade_service.dart';

class TradeService {
  TradeService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<TradeResponseAnonymous> startTrade(StartTradeRequest request) async {
    try {
      final response = await _dio.post(
        '/api/trades/start',
        data: request.toJson(),
      );

      return TradeResponseAnonymous.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TradeListResponse>> getTrades(int page, int pageSize) async {
    try {
      final response = await _dio.get(
        '/api/trades',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      final list = (response.data as List).cast<dynamic>();
      return list
          .map((e) => TradeListResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
