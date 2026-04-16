class OperationRecord {
  OperationRecord({
    required this.id,
    required this.tenantId,
    this.branchId,
    required this.customerId,
    required this.deviceId,
    this.technicianUserId,
    required this.title,
    required this.description,
    required this.status,
    required this.internalnote,
    required this.priority,
    required this.customerName,
    required this.technicianName,
    required this.occurredAtUtc,
    required this.type,
    this.maintenanceTemplateId,
    this.scheduledAtUtc,
  });

  final String id;
  final String tenantId;
  final String? branchId;
  final String customerId;
  final String deviceId;
  final String? technicianUserId;
  final String title;
  final String description;
  final String status;
  final String internalnote;
  final String priority;
  final String customerName;
  final String technicianName;
  final DateTime occurredAtUtc;
  final String type;
  final String? maintenanceTemplateId;
  final DateTime? scheduledAtUtc;

  factory OperationRecord.fromJson(Map<String, dynamic> json) {
    final occurred = json['occurredAtUtc'] ??
        json['OccurredAtUtc'] ??
        json['createdAtUtc'] ??
        json['CreatedAtUtc'];
    return OperationRecord(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId'])?.toString(),
      customerId: (json['customerId'] ?? json['CustomerId']).toString(),
      deviceId: (json['deviceId'] ?? json['DeviceId']).toString(),
      technicianUserId:
          (json['technicianUserId'] ?? json['TechnicianUserId'])?.toString(),
      title: (json['title'] ?? json['Title']).toString(),
      description: (json['description'] ?? json['Description']).toString(),
      status: (json['status'] ?? json['Status']).toString(),
      internalnote:
          (json['internalNote'] ?? json['InternalNote'] ?? '').toString(),
      priority: (json['priority'] ?? json['Priority']).toString(),
      occurredAtUtc: DateTime.parse(occurred.toString()),
      type: (json['type'] ?? json['Type']).toString(),
      maintenanceTemplateId:
          (json['maintenanceTemplateId'] ?? json['MaintenanceTemplateId'])
              ?.toString(),
      customerName:
          (json['customerName'] ?? json['CustomerName'] ?? '').toString(),
      technicianName:
          (json['technicianName'] ?? json['TechnicianName'] ?? '').toString(),
      scheduledAtUtc:
          _parseOptionalDate(json['scheduledAtUtc'] ?? json['ScheduledAtUtc']),
    );
  }
}

DateTime? _parseOptionalDate(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  if (s.isEmpty) return null;
  return DateTime.parse(s);
}
