class OfferSummary {
  OfferSummary(
      {required this.id,
      required this.tenantId,
      this.branchId,
      required this.operationId,
      required this.technicianUserId,
      this.customerId,
      required this.amount,
      required this.currency,
      required this.createdAt,
      required this.items});

  final String id;
  final String tenantId;
  final String? branchId;
  final String operationId;
  final String technicianUserId;
  final String? customerId;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final List<OfferItem> items;

  factory OfferSummary.fromJson(Map<String, dynamic> json) {
    return OfferSummary(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId'])?.toString(),
      operationId: (json['operationId'] ?? json['OperationId']).toString(),
      technicianUserId:
          (json['technicianUserId'] ?? json['TechnicianUserId']).toString(),
      customerId: (json['customerId'] ?? json['CustomerId'])?.toString(),
      amount: _parseDouble(json['amount'] ?? json['Amount']),
      currency: (json['currency'] ?? json['Currency']).toString(),
      createdAt:
          DateTime.parse((json['createdAt'] ?? json['CreatedAt']).toString()),
      items: ((json['items'] as List?) ?? [])
          .cast<dynamic>()
          .map((e) => OfferItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OfferItem {
  OfferItem({
    required this.stockItemId,
    required this.quantity,
    required this.unitPrice,
  });

  final String stockItemId;
  final int quantity;
  final double unitPrice;

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    return OfferItem(
      stockItemId: (json['stockItemId'] ?? json['StockItemId']).toString(),
      quantity: _parseInt(json['quantity'] ?? json['Quantity']),
      unitPrice: _parseDouble(json['unitPrice'] ?? json['UnitPrice']),
    );
  }
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

double _parseDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
