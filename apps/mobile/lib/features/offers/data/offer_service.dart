import 'package:dio/dio.dart';
import 'dart:typed_data';
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

  Future<bool> approveAdmin(String offerId) async {
    final response = await _dio.post('/api/offer/approve/admin/$offerId');
    if (response.statusCode == 200) {
      if (response.data is bool) return response.data == true;
      return (response.data['success'] ?? response.data['Success']) == true;
    }
    throw Exception('Failed to approve offer: ${response.statusCode}');
  }

  Future<bool> approveCustomer(String offerId) async {
    final response = await _dio.post('/api/offer/approve/customer/$offerId');
    if (response.statusCode == 200) {
      if (response.data is bool) return response.data == true;
      return (response.data['success'] ?? response.data['Success']) == true;
    }
    throw Exception('Failed to approve offer: ${response.statusCode}');
  }

  Future<bool> rejectAdmin(String offerId) async {
    final response = await _dio.post('/api/offer/reject/admin/$offerId');
    if (response.statusCode == 200) {
      if (response.data is bool) return response.data == true;
      return (response.data['success'] ?? response.data['Success']) == true;
    }
    throw Exception('Failed to reject offer: ${response.statusCode}');
  }

  Future<bool> rejectCustomer(String offerId) async {
    final response = await _dio.post('/api/offer/reject/customer/$offerId');
    if (response.statusCode == 200) {
      if (response.data is bool) return response.data == true;
      return (response.data['success'] ?? response.data['Success']) == true;
    }
    throw Exception('Failed to reject offer: ${response.statusCode}');
  }

  Future<Uint8List> getOfferInvoicePdf(String offerId) async {
    final invoiceNumber = 'OFR-${offerId.replaceAll('-', '').toLowerCase()}';

    late final Response invoiceRes;
    try {
      invoiceRes =
          await _dio.get('/api/accounting/invoices/by-number/$invoiceNumber');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        throw Exception(
            'Bu teklif için henüz fatura oluşmamış. Admin onayı sonrası tekrar deneyin.');
      }
      rethrow;
    }

    if (invoiceRes.statusCode != 200) {
      throw Exception('Fatura bulunamadı: ${invoiceRes.statusCode}');
    }

    final invoiceId = (invoiceRes.data['id'] ?? invoiceRes.data['Id'])?.toString();
    if (invoiceId == null || invoiceId.isEmpty) {
      throw Exception('Fatura kimliği alınamadı');
    }

    final pdfRes = await _dio.get<List<int>>(
      '/api/accounting/invoices/$invoiceId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );

    if (pdfRes.statusCode != 200 || pdfRes.data == null) {
      throw Exception('PDF yüklenemedi: ${pdfRes.statusCode}');
    }

    return Uint8List.fromList(pdfRes.data!);
  }
}
