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
