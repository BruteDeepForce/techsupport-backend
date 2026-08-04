import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/customer_models.dart';

class CustomerService {
  CustomerService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<String?> createCustomer(CustomerCreateRequest request) async {
    final res = await _dio.post('/api/customers', data: request.toJson());
    if (res.statusCode == 202 || res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['correlationId'] != null) {
        return data['correlationId'].toString();
      }
      return null;
    }
    throw Exception('Failed to create customer: ${res.statusCode}');
  }

  Future<List<Customer>> listCustomers() async {
    final res = await _dio.get('/api/customers');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load customers: ${res.statusCode}');
  }
}
