class StartTradeRequest {
  StartTradeRequest({
    this.existingCustomerId,
    this.existingCustomerName,
    this.existingCusomerAppUserId,
    this.existingDeviceId,
    this.categoryId,
    this.customer,
    this.device,
    this.type,
    this.paymentMethod,
    this.quantity = 1,
    this.unitPrice,
    this.totalAmount,
    this.costPrice,
    this.paidAmount,
    this.imeiOrSerial,
    this.notes,
  });

  final String? existingCustomerId;
  final String? existingCustomerName;
  final String? existingCusomerAppUserId;
  final String? existingDeviceId;
  final String? categoryId;
  final StartTradeCustomerPayload? customer;
  final StartTradeDevicePayload? device;
  final TradeType? type;
  final TradePaymentMethod? paymentMethod;
  final int quantity;
  final double? unitPrice;
  final double? totalAmount;
  final double? costPrice;
  final double? paidAmount;
  final String? imeiOrSerial;
  final String? notes;

  factory StartTradeRequest.fromJson(Map<String, dynamic> json) =>
      StartTradeRequest(
        existingCustomerId: json['existingCustomerId']?.toString(),
        existingCustomerName: json['existingCustomerName']?.toString(),
        existingCusomerAppUserId: json['existingCusomerAppUserId']?.toString(),
        existingDeviceId: json['existingDeviceId']?.toString(),
        categoryId: json['categoryId']?.toString(),
        customer: json['customer'] != null
            ? StartTradeCustomerPayload.fromJson(
                json['customer'] as Map<String, dynamic>,
              )
            : null,
        device: json['device'] != null
            ? StartTradeDevicePayload.fromJson(
                json['device'] as Map<String, dynamic>,
              )
            : null,
        type: _parseTradeType(json['type']),
        paymentMethod: _parseTradePaymentMethod(json['paymentMethod']),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble(),
        totalAmount: (json['totalAmount'] as num?)?.toDouble(),
        costPrice: (json['costPrice'] as num?)?.toDouble(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble(),
        imeiOrSerial: json['imeiOrSerial']?.toString(),
        notes: json['notes']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'existingCustomerId': existingCustomerId,
        'existingCustomerName': existingCustomerName,
        'existingCusomerAppUserId': existingCusomerAppUserId,
        'existingDeviceId': existingDeviceId,
        'categoryId': categoryId,
        'customer': customer?.toJson(),
        'device': device?.toJson(),
        'type': type?.name,
        'paymentMethod': paymentMethod?.name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'costPrice': costPrice,
        'paidAmount': paidAmount,
        'imeiOrSerial': imeiOrSerial,
        'notes': notes,
      }..removeWhere((key, value) => value == null);
}

class StartTradeCustomerPayload {
  StartTradeCustomerPayload({
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.temporaryPassword,
  });

  final String name;
  final String email;
  final String? phoneNumber;
  final String temporaryPassword;

  factory StartTradeCustomerPayload.fromJson(Map<String, dynamic> json) =>
      StartTradeCustomerPayload(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString(),
        temporaryPassword: json['temporaryPassword']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'temporaryPassword': temporaryPassword,
      }..removeWhere((key, value) => value == null);
}

class StartTradeDevicePayload {
  StartTradeDevicePayload({
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.sku,
    this.problemDescription,
    this.guaranteePeriod,
    this.warrantyStartAtUtc,
    this.barcodeNumber,
    this.customerName,
    this.status = 'Other',
  });

  final String brand;
  final String model;
  final String serialNumber;
  final String? sku;
  final String? problemDescription;
  final int? guaranteePeriod;
  final DateTime? warrantyStartAtUtc;
  final String? barcodeNumber;
  final String? customerName;
  final String status;

  factory StartTradeDevicePayload.fromJson(Map<String, dynamic> json) =>
      StartTradeDevicePayload(
        brand: json['brand']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        serialNumber: json['serialNumber']?.toString() ?? '',
        sku: json['sku']?.toString(),
        problemDescription: json['problemDescription']?.toString(),
        guaranteePeriod: (json['guaranteePeriod'] as num?)?.toInt(),
        warrantyStartAtUtc: json['warrantyStartAtUtc'] != null
            ? DateTime.tryParse(json['warrantyStartAtUtc'].toString())
            : null,
        barcodeNumber: json['barcodeNumber']?.toString(),
        customerName: json['customerName']?.toString(),
        status: json['status']?.toString() ?? 'Other',
      );

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'serialNumber': serialNumber,
        'sku': sku,
        'problemDescription': problemDescription,
        'guaranteePeriod': guaranteePeriod,
        'warrantyStartAtUtc': warrantyStartAtUtc?.toUtc().toIso8601String(),
        'barcodeNumber': barcodeNumber,
        'customerName': customerName,
        'status': status,
      }..removeWhere((key, value) => value == null);
}

class TradeResponseAnonymous {
  TradeResponseAnonymous({
    required this.tradeId,
    required this.idempotencyKey,
  });

  final String tradeId;
  final String idempotencyKey;

  factory TradeResponseAnonymous.fromJson(Map<String, dynamic> json) =>
      TradeResponseAnonymous(
        tradeId: json['tradeId']?.toString() ?? '',
        idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      );
}

class TradeResponse {
  TradeResponse({
    required this.id,
    this.tenantId,
    this.branchId,
    this.customerId,
    this.deviceId,
    required this.type,
    required this.paymentMethod,
    required this.status,
    this.deviceInfo,
    this.imeiOrSerial,
    required this.quantity,
    required this.unitPrice,
    this.costPrice,
    required this.totalAmount,
    this.paidAmount,
    this.notes,
    required this.createdAtUtc,
    this.completedAtUtc,
    required this.idempotencyKey,
  });

  final String id;
  final String? tenantId;
  final String? branchId;
  final String? customerId;
  final String? deviceId;
  final TradeType type;
  final TradePaymentMethod paymentMethod;
  final TradeStatus status;
  final TradeDeviceInfo? deviceInfo;
  final String? imeiOrSerial;
  final int quantity;
  final double unitPrice;
  final double? costPrice;
  final double totalAmount;
  final double? paidAmount;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime? completedAtUtc;
  final String idempotencyKey;

  factory TradeResponse.fromJson(Map<String, dynamic> json) => TradeResponse(
        id: json['id']?.toString() ?? '',
        tenantId: json['tenantId']?.toString(),
        branchId: json['branchId']?.toString(),
        customerId: json['customerId']?.toString(),
        deviceId: json['deviceId']?.toString(),
        type: _parseTradeType(json['type']) ?? TradeType.sale,
        paymentMethod: _parseTradePaymentMethod(json['paymentMethod']) ??
            TradePaymentMethod.cash,
        status: _parseTradeStatus(json['status']) ?? TradeStatus.pending,
        deviceInfo: json['deviceInfo'] != null
            ? TradeDeviceInfo.fromJson(
                json['deviceInfo'] as Map<String, dynamic>)
            : null,
        imeiOrSerial: json['imeiOrSerial']?.toString(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        costPrice: (json['costPrice'] as num?)?.toDouble(),
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble(),
        notes: json['notes']?.toString(),
        createdAtUtc: DateTime.parse(json['createdAtUtc'].toString()),
        completedAtUtc: json['completedAtUtc'] != null
            ? DateTime.tryParse(json['completedAtUtc'].toString())
            : null,
        idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      );
}

class TradeDeviceInfo {
  TradeDeviceInfo({
    this.tradeId,
    this.tenantId,
    this.branchId,
    this.customerId,
    required this.idempotencyKey,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.problemDescription,
    this.guaranteePeriod,
    this.warrantyStartAtUtc,
    this.barcodeNumber,
    this.customerName,
    this.status,
    this.isActive,
    this.occurredAtUtc,
  });

  final String? tradeId;
  final String? tenantId;
  final String? branchId;
  final String? customerId;
  final String idempotencyKey;
  final String brand;
  final String model;
  final String serialNumber;
  final String? problemDescription;
  final int? guaranteePeriod;
  final DateTime? warrantyStartAtUtc;
  final String? barcodeNumber;
  final String? customerName;
  final String? status;
  final bool? isActive;
  final DateTime? occurredAtUtc;

  factory TradeDeviceInfo.fromJson(Map<String, dynamic> json) =>
      TradeDeviceInfo(
        tradeId: json['tradeId']?.toString(),
        tenantId: json['tenantId']?.toString(),
        branchId: json['branchId']?.toString(),
        customerId: json['customerId']?.toString(),
        idempotencyKey: json['idempotencyKey']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        serialNumber: json['serialNumber']?.toString() ?? '',
        problemDescription: json['problemDescription']?.toString(),
        guaranteePeriod: (json['guaranteePeriod'] as num?)?.toInt(),
        warrantyStartAtUtc: json['warrantyStartAtUtc'] != null
            ? DateTime.tryParse(json['warrantyStartAtUtc'].toString())
            : null,
        barcodeNumber: json['barcodeNumber']?.toString(),
        customerName: json['customerName']?.toString(),
        status: json['status']?.toString(),
        isActive: json['isActive'] as bool?,
        occurredAtUtc: json['occurredAtUtc'] != null
            ? DateTime.tryParse(json['occurredAtUtc'].toString())
            : null,
      );
}

class TradeListResponse {
  TradeListResponse({
    this.tradeId,
    this.customerId,
    this.customerName,
    this.deviceName,
    this.type,
    this.paymentMethod,
    this.totalAmount,
    this.createdAt,
    this.deviceId,
    this.status,
    this.page,
    this.pageSize,
    this.existingCount,
  });
  final String? tradeId;
  final String? customerId;
  final String? customerName;
  final String? deviceName;
  final String? type;
  final String? paymentMethod;
  final double? totalAmount;
  final DateTime? createdAt;
  final String? deviceId;
  final String? status;
  final int? page;
  final int? pageSize;
  final int? existingCount;

  factory TradeListResponse.fromJson(Map<String, dynamic> json) =>
      TradeListResponse(
        tradeId: json['TradeId']?.toString() ?? json['tradeId']?.toString(),
        customerId:
            json['customerId']?.toString() ?? json['CustomerId']?.toString(),
        customerName: json['customerName']?.toString() ??
            json['CustomerName']?.toString(),
        deviceName:
            json['deviceName']?.toString() ?? json['DeviceName']?.toString(),
        type: json['type']?.toString() ?? json['Type']?.toString(),
        paymentMethod: json['paymentMethod']?.toString() ??
            json['PaymentMethod']?.toString(),
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
            (json['TotalAmount'] as num?)?.toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        deviceId: json['deviceId']?.toString() ?? json['DeviceId']?.toString(),
        status: json['status']?.toString() ?? json['Status']?.toString(),
        page:
            (json['page'] as num?)?.toInt() ?? (json['Page'] as num?)?.toInt(),
        pageSize: (json['pageSize'] as num?)?.toInt() ??
            (json['PageSize'] as num?)?.toInt(),
        existingCount: (json['existingCount'] as num?)?.toInt() ??
            (json['ExistingCount'] as num?)?.toInt(),
      );
}

enum TradeType { sale, purchase, tradeIn }

enum TradePaymentMethod { cash, card, transfer }

enum TradeStatus { pending, completed, cancelled, failed }

TradeType? _parseTradeType(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value == 1) return TradeType.sale;
    if (value == 2) return TradeType.purchase;
    if (value == 3) return TradeType.tradeIn;
    return null;
  }

  switch (value.toString().toLowerCase()) {
    case 'sale':
      return TradeType.sale;
    case 'purchase':
      return TradeType.purchase;
    case 'tradein':
      return TradeType.tradeIn;
    default:
      return null;
  }
}

TradePaymentMethod? _parseTradePaymentMethod(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value == 1) return TradePaymentMethod.cash;
    if (value == 2) return TradePaymentMethod.card;
    if (value == 3) return TradePaymentMethod.transfer;
    return null;
  }

  switch (value.toString().toLowerCase()) {
    case 'cash':
      return TradePaymentMethod.cash;
    case 'card':
      return TradePaymentMethod.card;
    case 'transfer':
      return TradePaymentMethod.transfer;
    default:
      return null;
  }
}

TradeStatus? _parseTradeStatus(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value == 1) return TradeStatus.pending;
    if (value == 2) return TradeStatus.completed;
    if (value == 3) return TradeStatus.cancelled;
    if (value == 4) return TradeStatus.failed;
    return null;
  }

  switch (value.toString().toLowerCase()) {
    case 'pending':
      return TradeStatus.pending;
    case 'completed':
      return TradeStatus.completed;
    case 'cancelled':
      return TradeStatus.cancelled;
    case 'failed':
      return TradeStatus.failed;
    default:
      return null;
  }
}
