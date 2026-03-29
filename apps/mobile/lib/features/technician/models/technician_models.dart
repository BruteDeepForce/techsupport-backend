class Technician {
  Technician({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.isActive,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final bool isActive;

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        id: (json['id'] ??
                    json['Id'] ??
                    json['technicianId'] ??
                    json['TechnicianId'])
                ?.toString() ??
            '',
        firstName: (json['firstName'] ??
                    json['FirstName'] ??
                    json['name'] ??
                    json['Name'])
                ?.toString() ??
            '',
        lastName: (json['lastName'] ?? json['LastName'])?.toString(),
        email: (json['email'] ?? json['Email'])?.toString() ?? '',
        phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
        isActive: (json['isActive'] ?? json['IsActive'] ?? false) is bool
            ? (json['isActive'] ?? json['IsActive'] ?? false) as bool
            : ((json['isActive'] ?? json['IsActive'] ?? 'false')
                    .toString()
                    .toLowerCase() ==
                'true'),
      );
}
