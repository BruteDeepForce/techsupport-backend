class DeviceDTO {
  final String brand;
  final String model;
  final String serialNumber;
  final String? problemDescription;
  final int? guaranteePeriod;
  final DateTime? warrantyStartAtUtc;
  final String? barcodeNumber;
  final String? customerId;
  final String? customerName;
  final String status;

  DeviceDTO({
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.problemDescription,
    this.guaranteePeriod,
    this.warrantyStartAtUtc,
    this.barcodeNumber,
    this.customerId,
    this.customerName,
    required this.status,
  });
}

class DeviceRecord {
  DeviceRecord({
    required this.id,
    required this.tenantId,
    required this.branchId,
    this.customerId,
    this.customerName,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.problemDescription,
    this.guaranteePeriod,
    this.warrantyStartAtUtc,
    this.warrantyEndAtUtc,
    this.barcodeNumber,
    required this.status,
    required this.isActive,
    this.createdAtUtc,
    this.updatedAtUtc,
    this.deactivatedAtUtc,
  });

  final String id;
  final String tenantId;
  final String branchId;
  final String? customerId;
  final String? customerName;
  final String brand;
  final String model;
  final String serialNumber;
  final String? problemDescription;
  final int? guaranteePeriod;
  final DateTime? warrantyStartAtUtc;
  final DateTime? warrantyEndAtUtc;
  final String? barcodeNumber;
  final String status;
  final bool isActive;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;
  final DateTime? deactivatedAtUtc;

  factory DeviceRecord.fromJson(Map<String, dynamic> json) {
    return DeviceRecord(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId']).toString(),
      customerId: (json['customerId'] ?? json['CustomerId'])?.toString(),
      customerName: (json['customerName'] ?? json['CustomerName'])?.toString(),
      brand: (json['brand'] ?? json['Brand']).toString(),
      model: (json['model'] ?? json['Model']).toString(),
      serialNumber: (json['serialNumber'] ?? json['SerialNumber']).toString(),
      problemDescription:
          (json['problemDescription'] ?? json['ProblemDescription'])
              ?.toString(),
      guaranteePeriod:
          (json['guaranteePeriod'] ?? json['GuaranteePeriod']) as int?,
      warrantyStartAtUtc: _parseDate(
          json['warrantyStartAtUtc'] ?? json['WarrantyStartAtUtc']),
      warrantyEndAtUtc:
          _parseDate(json['warrantyEndAtUtc'] ?? json['WarrantyEndAtUtc']),
      barcodeNumber: (json['barcodeNumber'] ?? json['BarcodeNumber'])
          ?.toString(),
      status: (json['status'] ?? json['Status']).toString(),
      isActive: (json['isActive'] ?? json['IsActive']) == true,
      createdAtUtc:
          _parseDate(json['createdAtUtc'] ?? json['CreatedAtUtc']),
      updatedAtUtc:
          _parseDate(json['updatedAtUtc'] ?? json['UpdatedAtUtc']),
      deactivatedAtUtc:
          _parseDate(json['deactivatedAtUtc'] ?? json['DeactivatedAtUtc']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}
