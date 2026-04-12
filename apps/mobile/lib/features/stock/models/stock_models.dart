class StockCategory {
  StockCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory StockCategory.fromJson(Map<String, dynamic> json) {
    return StockCategory(
      id: (json['id'] ?? json['Id']).toString(),
      name: (json['name'] ?? json['Name']).toString(),
    );
  }
}

class StockItem {
  StockItem({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    this.description,
    this.unit,
    this.unitPrice,
    this.categoryId,
    this.categoryName,
    required this.quantityAvailable,
    required this.quantityReserved,
    required this.createdAtUtc,
  });

  final String id;
  final String sku;
  final String barcode;
  final String name;
  final String? description;
  final String? unit;
  final double? unitPrice;
  final String? categoryId;
  final String? categoryName;
  final int quantityAvailable;
  final int quantityReserved;
  final DateTime createdAtUtc;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: (json['id'] ?? json['Id']).toString(),
      sku: (json['sku'] ?? json['Sku']).toString(),
      barcode: (json['barcode'] ?? json['Barcode']).toString(),
      name: (json['name'] ?? json['Name']).toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      unit: (json['unit'] ?? json['Unit'])?.toString(),
      unitPrice: _parseDouble(json['unitPrice'] ?? json['UnitPrice']),
      categoryId: (json['categoryId'] ?? json['CategoryId'])?.toString(),
      categoryName: (json['categoryName'] ?? json['CategoryName'])?.toString(),
      quantityAvailable: _parseInt(
          json['quantityAvailable'] ?? json['QuantityAvailable']),
      quantityReserved:
          _parseInt(json['quantityReserved'] ?? json['QuantityReserved']),
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
    );
  }
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}

