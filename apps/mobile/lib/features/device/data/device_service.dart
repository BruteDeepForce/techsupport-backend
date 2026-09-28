import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../model/device_model.dart';

class DeviceService {
  DeviceService({Dio? dio}) : _dio = dio ?? ApiClient().dio;
  final Dio _dio;

  Future<List<DeviceRecord>> getDevices() async {
    final response = await _dio.get('/api/devices');
    if (response.statusCode == 200) {
      final list = (response.data as List).cast<dynamic>();
      return list
          .map((e) => DeviceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load devices: ${response.statusCode}');
  }

  Future<DeviceRecord> getDeviceById(String id) async {
    final response = await _dio.get('/api/devices/$id');
    if (response.statusCode == 200) {
      return DeviceRecord.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load device info: ${response.statusCode}');
  }

  Future<List<DeviceRecord>> getCustomerDevices(String? customerId) async {
    final response = await _dio.get('/api/devices/customer/$customerId');
    if (response.statusCode == 200) {
      final list = (response.data as List).cast<dynamic>();
      return list
          .map((e) => DeviceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load customer devices: ${response.statusCode}');
  }

  Future<void> createDevice(DeviceDTO device) async {
    final response = await _dio.post('/api/devices', data: {
      'brand': device.brand,
      'model': device.model,
      'serialNumber': device.serialNumber,
      'problemDescription': device.problemDescription,
      'guaranteePeriod': device.guaranteePeriod,
      'warrantyStartAtUtc': device.warrantyStartAtUtc?.toIso8601String(),
      'barcodeNumber': device.barcodeNumber,
      'customerId': device.customerId,
      'appUserId': device.appUserId,
      'customerName': device.customerName,
      'status': device.status,
      'currentSalePrice': device.currentSalePrice,
      'productCondition': device.productCondition,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to create device: ${response.statusCode}');
    }
  }

  Future<DeviceRecord> createInventoryDevice({
    required String brand,
    required String model,
    required String serialNumber,
    required String categoryId,
    required String sku,
    required String barcodeNumber,
    required double currentSalePrice,
    required String productCondition,
    int? guaranteePeriod,
    DateTime? warrantyStartAtUtc,
    String? problemDescription,
    String? description,
    String? unit,
    int quantity = 1,
  }) async {
    final response = await _dio.post('/api/devices/inventory', data: {
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'categoryId': categoryId,
      'sku': sku,
      'barcodeNumber': barcodeNumber,
      'currentSalePrice': currentSalePrice,
      'productCondition': productCondition,
      'guaranteePeriod': guaranteePeriod,
      'warrantyStartAtUtc': warrantyStartAtUtc?.toIso8601String(),
      'problemDescription': problemDescription,
      'description': description,
      'unit': unit,
      'quantity': quantity,
    });
    if (response.statusCode == 200) {
      return DeviceRecord.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create inventory device: ${response.statusCode}');
  }
}
