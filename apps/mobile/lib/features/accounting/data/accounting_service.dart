import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/accounting_models.dart';

class AccountingService {
  AccountingService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<AccountingDashboardData> getDashboard({int pageSize = 50}) async {
    final responses = await Future.wait<Response<dynamic>>([
      _dio.get('/api/accounting/accounts', queryParameters: {
        'page': 1,
        'pageSize': pageSize,
      }),
      _dio.get('/api/accounting/invoices', queryParameters: {
        'page': 1,
        'pageSize': pageSize,
      }),
      _dio.get('/api/accounting/payments', queryParameters: {
        'page': 1,
        'pageSize': pageSize,
      }),
      _dio.get('/api/accounting/cari-hesaplar/hareketler', queryParameters: {
        'page': 1,
        'pageSize': pageSize,
      }),
      _dio.get('/api/accounting/invoices/receivable'),
    ]);

    return AccountingDashboardData(
      accounts: _pagedItems(responses[0].data)
          .map(AccountingAccount.fromJson)
          .toList(),
      invoices: _pagedItems(responses[1].data)
          .map(AccountingInvoice.fromJson)
          .toList(),
      payments: _pagedItems(responses[2].data)
          .map(AccountingPayment.fromJson)
          .toList(),
      movements: _listItems(responses[3].data)
          .map(AccountingMovement.fromJson)
          .toList(),
      totalReceivable: _asDouble(responses[4].data),
    );
  }

  Future<Uint8List> downloadInvoicePdf(String invoiceId) async {
    final response = await _dio.get<List<int>>(
      '/api/accounting/invoices/$invoiceId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.data == null) {
      throw StateError('Fatura PDF dosyası alınamadı.');
    }
    return Uint8List.fromList(response.data!);
  }

  List<Map<String, dynamic>> _pagedItems(dynamic data) {
    if (data is! Map) return const [];
    return _listItems(data['items'] ?? data['Items']);
  }

  List<Map<String, dynamic>> _listItems(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
