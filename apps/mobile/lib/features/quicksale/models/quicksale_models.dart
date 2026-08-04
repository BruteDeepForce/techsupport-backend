class QuickSaleStockItem {
  final String id;
  final String name;
  final String sku;
  final int availableQuantity;

  QuickSaleStockItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.availableQuantity,
  });

  factory QuickSaleStockItem.fromJson(Map<String, dynamic> json) {
    final balances = (json['balances'] as List?) ?? const [];
    var quantity = 0;
    if (balances.isNotEmpty) {
      final first = balances.first as Map<String, dynamic>;
      quantity = (first['quantityAvailable'] as num?)?.toInt() ?? 0;
    }

    return QuickSaleStockItem(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '-',
      sku: json['sku'] as String? ?? '-',
      availableQuantity: quantity,
    );
  }
}

class QuickSaleCartLine {
  final QuickSaleStockItem item;
  final int quantity;
  final double unitPrice;

  QuickSaleCartLine({
    required this.item,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;

  QuickSaleCartLine copyWith({int? quantity, double? unitPrice}) {
    return QuickSaleCartLine(
      item: item,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class QuickSaleSummary {
  final String id;
  final String saleNumber;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAtUtc;

  QuickSaleSummary({
    required this.id,
    required this.saleNumber,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAtUtc,
  });

  factory QuickSaleSummary.fromJson(Map<String, dynamic> json) {
    return QuickSaleSummary(
      id: json['id'].toString(),
      saleNumber: json['saleNumber'] as String? ?? '-',
      status: json['status'] as String? ?? '-',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '-',
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
