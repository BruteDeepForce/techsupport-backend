import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/offer_models.dart';

class OfferService {
  OfferService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<OfferSummary>> getOffersToAdminAsync() async {
    final res = await _dio.get('/api/offer/offers/admin');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => OfferSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load offers: ${res.statusCode}');
  }

  Future<List<OfferSummary>> getOffersToCustomerAsync() async {
    final res = await _dio.get('/api/offer/offers/customer');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => OfferSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load offers: ${res.statusCode}');
  }

  Future<OfferSummary> getOfferById(String offerId) async {
    final res = await _dio.get('/api/offer/$offerId/offer');
    if (res.statusCode == 200) {
      return OfferSummary.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load offer: ${res.statusCode}');
  }
}
