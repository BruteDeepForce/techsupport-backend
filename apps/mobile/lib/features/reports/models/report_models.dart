class ReportSummary {
  ReportSummary(
      {required this.id,
      required this.name,
      this.description,
      required this.generatedAtUtc,
      required this.createdAtUtc});

  final String id;
  final String name;
  final String? description;
  final DateTime generatedAtUtc;
  final DateTime createdAtUtc;

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        id: (json['id'] as String?) ?? (json['Id']?.toString() ?? ''),
        name: json['name'] as String? ?? json['Name'] as String? ?? '',
        description:
            json['description'] as String? ?? json['Description'] as String?,
        generatedAtUtc: DateTime.parse(
            (json['generatedAtUtc'] ?? json['GeneratedAtUtc']).toString()),
        createdAtUtc: DateTime.parse(
            (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
      );
}

class ReportMetric {
  ReportMetric(
      {required this.metricType,
      required this.periodType,
      this.periodDate,
      required this.value});

  final String metricType;
  final String periodType;
  final String? periodDate;
  final int value;

  factory ReportMetric.fromJson(Map<String, dynamic> json) => ReportMetric(
        metricType: (json['metricType'] ?? json['MetricType']).toString(),
        periodType: (json['periodType'] ?? json['PeriodType']).toString(),
        periodDate: (json['periodDate'] ?? json['PeriodDate'])?.toString(),
        value: (json['value'] ?? json['Value']) is int
            ? json['value'] ?? json['Value']
            : int.parse((json['value'] ?? json['Value']).toString()),
      );
}

class TechnicianSummary {
  TechnicianSummary(
      {required this.technicianUserId,
      required this.name,
      required this.email,
      this.phoneNumber});

  final String technicianUserId;
  final String name;
  final String email;
  final String? phoneNumber;

  factory TechnicianSummary.fromJson(Map<String, dynamic> json) =>
      TechnicianSummary(
        technicianUserId: (json['technicianUserId'] ?? json['TechnicianUserId'])
                ?.toString() ??
            '',
        name: (json['name'] ?? json['Name'])?.toString() ?? '',
        email: (json['email'] ?? json['Email'])?.toString() ?? '',
        phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
      );
}

class PagedResult<T> {
  PagedResult(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total});

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  factory PagedResult.fromJson(
      Map<String, dynamic> json, T Function(dynamic) itemParser) {
    final items = <T>[];
    if (json['items'] is List) {
      for (final it in json['items']) {
        items.add(itemParser(it));
      }
    }
    return PagedResult<T>(
      items: items,
      page: (json['page'] ?? json['Page'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? json['PageSize'] ?? 20) as int,
      total: (json['total'] ?? json['Total'] ?? 0) is int
          ? (json['total'] ?? json['Total'] ?? 0) as int
          : int.parse((json['total'] ?? json['Total'] ?? '0').toString()),
    );
  }
}

class TenantDashboard {
  TenantDashboard({
    required this.summary,
    required this.metrics,
    required this.plannedOperations,
  });

  final TenantReportSummary summary;
  final List<TenantReportMetric> metrics;
  final List<PlannedOperationSnapshot> plannedOperations;

  factory TenantDashboard.fromJson(Map<String, dynamic> json) {
    final metricsJson = json['metrics'] ?? json['Metrics'];
    final plannedOperationsJson =
        json['plannedOperations'] ?? json['PlannedOperations'];
    return TenantDashboard(
      summary: TenantReportSummary.fromJson(
          (json['summary'] ?? json['Summary'] ?? {}) as Map<String, dynamic>),
      metrics: metricsJson is List
          ? metricsJson
              .whereType<Map>()
              .map((e) =>
                  TenantReportMetric.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <TenantReportMetric>[],
      plannedOperations: plannedOperationsJson is List
          ? plannedOperationsJson
              .whereType<Map>()
              .map((e) => PlannedOperationSnapshot.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : <PlannedOperationSnapshot>[],
    );
  }

  int metricValue(String metricType, String periodType, DateTime periodStart) {
    final normalizedDate =
        '${periodStart.year.toString().padLeft(4, '0')}-${periodStart.month.toString().padLeft(2, '0')}-${periodStart.day.toString().padLeft(2, '0')}';
    for (final metric in metrics) {
      if (metric.metricType == metricType &&
          metric.periodType == periodType &&
          metric.periodStart == normalizedDate) {
        return metric.value;
      }
    }
    return 0;
  }

  int metricTotal(String metricType) {
    var total = 0;
    for (final metric in metrics) {
      if (metric.metricType == metricType) {
        total += metric.value;
      }
    }
    return total;
  }
}

class PlannedOperationSnapshot {
  PlannedOperationSnapshot({
    required this.id,
    required this.tenantId,
    this.branchId,
    required this.scheduledAtUtc,
    required this.toTechnicianUserId,
    required this.technicianFullName,
    this.customerId,
    required this.customerName,
    required this.title,
    required this.description,
    required this.operationId,
  });

  final String id;
  final String tenantId;
  final String? branchId;
  final DateTime scheduledAtUtc;
  final String toTechnicianUserId;
  final String technicianFullName;
  final String? customerId;
  final String customerName;
  final String title;
  final String description;
  final String operationId;

  DateTime get scheduledAtLocal => scheduledAtUtc.toLocal();

  factory PlannedOperationSnapshot.fromJson(Map<String, dynamic> json) {
    return PlannedOperationSnapshot(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? json['TenantId'] ?? '').toString(),
      branchId: (json['branchId'] ?? json['BranchId'])?.toString(),
      scheduledAtUtc: DateTime.parse(
          (json['scheduledAtUtc'] ?? json['ScheduledAtUtc']).toString()),
      toTechnicianUserId:
          (json['toTechnicianUserId'] ?? json['ToTechnicianUserId'] ?? '')
              .toString(),
      technicianFullName:
          (json['technicianFullName'] ?? json['TechnicianFullName'] ?? '')
              .toString(),
      customerId: (json['customerId'] ?? json['CustomerId'])?.toString(),
      customerName:
          (json['customerName'] ?? json['CustomerName'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description:
          (json['description'] ?? json['Description'] ?? '').toString(),
      operationId:
          (json['operationId'] ?? json['OperationId'] ?? '').toString(),
    );
  }
}

class TenantReportSummary {
  TenantReportSummary({
    required this.tenantId,
    required this.tenantName,
    required this.totalCustomers,
    required this.totalOperations,
    required this.completedOperations,
    required this.failedOperations,
    required this.deliveredOperations,
    required this.openOperations,
  });

  final String tenantId;
  final String tenantName;
  final int totalCustomers;
  final int totalOperations;
  final int completedOperations;
  final int failedOperations;
  final int deliveredOperations;
  final int openOperations;

  factory TenantReportSummary.fromJson(Map<String, dynamic> json) {
    int asInt(String camel, String pascal) {
      final value = json[camel] ?? json[pascal] ?? 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return TenantReportSummary(
      tenantId: (json['tenantId'] ?? json['TenantId'] ?? '').toString(),
      tenantName: (json['tenantName'] ?? json['TenantName'] ?? '').toString(),
      totalCustomers: asInt('totalCustomers', 'TotalCustomers'),
      totalOperations: asInt('totalOperations', 'TotalOperations'),
      completedOperations: asInt('completedOperations', 'CompletedOperations'),
      failedOperations: asInt('failedOperations', 'FailedOperations'),
      deliveredOperations: asInt('deliveredOperations', 'DeliveredOperations'),
      openOperations: asInt('openOperations', 'OpenOperations'),
    );
  }
}

class TenantReportMetric {
  TenantReportMetric({
    required this.metricType,
    required this.periodType,
    required this.periodStart,
    required this.value,
  });

  final String metricType;
  final String periodType;
  final String periodStart;
  final int value;

  factory TenantReportMetric.fromJson(Map<String, dynamic> json) {
    final value = json['value'] ?? json['Value'] ?? 0;
    return TenantReportMetric(
      metricType: (json['metricType'] ?? json['MetricType']).toString(),
      periodType: (json['periodType'] ?? json['PeriodType']).toString(),
      periodStart: (json['periodStart'] ?? json['PeriodStart']).toString(),
      value: value is int ? value : int.tryParse(value.toString()) ?? 0,
    );
  }
}
