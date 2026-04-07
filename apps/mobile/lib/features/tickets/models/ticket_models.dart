class Ticket {
  Ticket({
    required this.id,
    required this.tenantId,
    this.branchId,
    required this.customerId,
    this.deviceId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAtUtc,
    this.convertedOperationId,
    this.customername,
  });

  final String id;
  final String tenantId;
  final String? branchId;
  final String customerId;
  final String? deviceId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAtUtc;
  final String? convertedOperationId;
  final String? customername;

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: (json['id'] ?? json['Id']).toString(),
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        branchId: (json['branchId'] ?? json['BranchId'])?.toString(),
        customerId: (json['customerId'] ?? json['CustomerId']).toString(),
        deviceId: (json['deviceId'] ?? json['DeviceId'])?.toString(),
        title: (json['title'] ?? json['Title']).toString(),
        description: (json['description'] ?? json['Description']).toString(),
        priority: (json['priority'] ?? json['Priority']).toString(),
        status: (json['status'] ?? json['Status']).toString(),
        createdAtUtc: DateTime.parse(
            (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
        convertedOperationId:
            (json['convertedOperationId'] ?? json['ConvertedOperationId'])
                ?.toString(),
        customername: (json['customerName'] ??
                json['CustomerName'] ??
                json['CustomerName'])
            ?.toString(),
      );
}

class TicketCreateRequest {
  TicketCreateRequest({
    required this.title,
    required this.description,
    this.deviceId,
    this.priority,
  });

  final String title;
  final String description;
  final String? deviceId;
  final String? priority;

  Map<String, dynamic> toJson() => {
        'DeviceId': deviceId,
        'Title': title,
        'Description': description,
        'Priority': priority,
      }..removeWhere((k, v) => v == null);
}

class ConvertTicketRequest {
  ConvertTicketRequest({
    required this.technicianId,
    required this.technicianName,
    required this.priority,
    required this.operationType,
    this.internalNote,
  });

  final String technicianId;
  final String technicianName;
  final String priority;
  final String operationType;
  final String? internalNote;

  Map<String, dynamic> toJson() => {
        'TechnicianInfo': {
          'TechnicianId': technicianId,
          'Name': technicianName,
        },
        'priority': priority,
        'operationType': operationType,
        'InternalNote': internalNote,
      }..removeWhere((k, v) => v == null || (v is String && v.isEmpty));
}
