import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/ticket_models.dart';

class TicketService {
  TicketService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<List<Ticket>> listTickets() async {
    final res = await _dio.get('/api/operations/tickets');
    if (res.statusCode == 200) {
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load tickets: ${res.statusCode}');
  }

  Future<Ticket> getTicket(String id) async {
    final res = await _dio.get('/api/operations/tickets/$id');
    if (res.statusCode == 200) {
      return Ticket.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load ticket: ${res.statusCode}');
  }

  Future<Ticket> createTicket(TicketCreateRequest request) async {
    final res = await _dio.post('/api/operations/tickets',
        data: request.toJson());
    if (res.statusCode == 200) {
      return Ticket.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create ticket: ${res.statusCode}');
  }

  Future<String> convertTicket(String id, ConvertTicketRequest request) async {
    final res = await _dio.post('/api/operations/tickets/$id/convert',
        data: request.toJson());
    if (res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>;
      final opId = data['operationId'] ?? data['OperationId'];
      if (opId != null) return opId.toString();
      return '';
    }
    throw Exception('Failed to convert ticket: ${res.statusCode}');
  }

  Future<Ticket> rejectTicket(String id, String reason) async {
    final res = await _dio.post('/api/operations/tickets/$id/reject',
        data: {'Reason': reason});
    if (res.statusCode == 200) {
      return Ticket.fromJson(res.data as Map<String, dynamic>);
    }
    final error = res.data is Map<String, dynamic>
        ? (res.data['error']?.toString() ?? '')
        : '';
    throw Exception(
        'Failed to reject ticket: ${res.statusCode} ${error.isEmpty ? '' : '- $error'}');
  }
}
