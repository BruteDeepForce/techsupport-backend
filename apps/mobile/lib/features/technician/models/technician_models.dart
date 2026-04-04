class Technician {
  Technician({
    required this.userId,
    required this.tenantId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.specializations,
    this.isActive,
  });

  final String userId;
  final String tenantId;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<String>? specializations;
  final bool? isActive;

  // Backend now uses TechnicianId == UserId. Keep a convenience alias.
  String get id => userId;

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        userId: (json['userId'] ?? json['UserId'] ?? json['id'] ?? json['Id'])
                ?.toString() ??
            '',
        tenantId: (json['tenantId'] ?? json['TenantId'])?.toString() ?? '',
        name: (json['name'] ?? json['Name'] ?? json['firstName'])
                ?.toString() ??
            '',
        email: (json['email'] ?? json['Email'])?.toString() ?? '',
        phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
        specializations: (json['specializations'] ??
                    json['Specializations']) is List
            ? (json['specializations'] ?? json['Specializations'])
                .map((e) => e.toString())
                .toList()
                .cast<String>()
            : null,
        isActive: json['isActive'] ?? json['IsActive'],
      );
}
