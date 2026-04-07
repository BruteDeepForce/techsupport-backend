class Customer {
  Customer({
    required this.id,
    this.appUserId,
    required this.tenantId,
    this.branchId,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  final String id;
  final String? appUserId;
  final String tenantId;
  final String? branchId;
  final String name;
  final String email;
  final String? phoneNumber;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: (json['id'] ?? json['Id']).toString(),
        appUserId: (json['appUserId'] ?? json['AppUserId'])?.toString(),
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        branchId: (json['branchId'] ?? json['BranchId'])?.toString(),
        name: (json['name'] ?? json['Name']).toString(),
        email: (json['email'] ?? json['Email']).toString(),
        phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
      );
}

class CustomerCreateRequest {
  CustomerCreateRequest({
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.temporaryPassword,
  });

  final String name;
  final String email;
  final String? phoneNumber;
  final String temporaryPassword;

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Email': email,
        'PhoneNumber': phoneNumber,
        'TemporaryPassword': temporaryPassword,
      }..removeWhere((k, v) => v == null);
}
