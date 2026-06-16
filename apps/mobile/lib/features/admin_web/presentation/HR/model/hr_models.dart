class HREmployeeLargeDetailResponse {
  final List<EmployeeResponse> employees;
  final int totalEmployees;
  final int activeCount;
  final int passiveCount;
  final int employeeOnLeaveCount;
  final int pendingLeavesCount;
  final int employeePendingAdvancesRequests;

  HREmployeeLargeDetailResponse({
    required this.employees,
    required this.totalEmployees,
    required this.activeCount,
    required this.passiveCount,
    required this.employeeOnLeaveCount,
    required this.pendingLeavesCount,
    required this.employeePendingAdvancesRequests,
  });

  factory HREmployeeLargeDetailResponse.fromJson(Map<String, dynamic> json) {
    return HREmployeeLargeDetailResponse(
      employees: (json['employees'] as List<dynamic>)
          .map((e) => EmployeeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEmployees: json['TotalCount'] ?? json['totalCount'] as int,
      activeCount: json['ActiveCount'] ?? json['activeCount'] as int,
      passiveCount: json['PassiveCount'] ?? json['passiveCount'] as int,
      employeeOnLeaveCount:
          json['EmployeesOnLeaveCount'] ?? json['employeesOnLeaveCount'] as int,
      pendingLeavesCount:
          json['PendingLeavesCount'] ?? json['pendingLeavesCount'] as int,
      employeePendingAdvancesRequests:
          json['EmployeesWithPendingAdvanceRequestsCount'] ??
              json['employeesWithPendingAdvanceRequestsCount'] as int,
    );
  }
}

class EmployeeResponse {
  final String id;
  final String tenantId;
  final String branchId;
  final String fullName;
  final String employeeNo;
  final String? departmentId;
  final String? positionId;
  final String? positionName;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final String status;
  final DateTime? jobsStartDateUtc;
  final DateTime? jobsEndDateUtc;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;
  final DateTime? deletedAtUtc;
  final String userId;

  EmployeeResponse({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.fullName,
    required this.employeeNo,
    this.departmentId,
    this.positionId,
    this.positionName,
    this.email,
    this.phone,
    this.profileImageUrl,
    required this.status,
    this.jobsStartDateUtc,
    this.jobsEndDateUtc,
    required this.createdAtUtc,
    this.updatedAtUtc,
    this.deletedAtUtc,
    required this.userId,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    final jobsStartDateValue =
        json['jobsStartDateUtc'] ?? json['JobsStartDateUtc'];

    final jobsEndDateValue = json['jobsEndDateUtc'] ?? json['JobsEndDateUtc'];

    final createdAtValue = json['createdAtUtc'] ?? json['CreatedAtUtc'];

    final updatedAtValue = json['updatedAtUtc'] ?? json['UpdatedAtUtc'];

    final deletedAtValue = json['deletedAtUtc'] ?? json['DeletedAtUtc'];

    return EmployeeResponse(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId']).toString(),
      fullName: (json['fullName'] ?? json['FullName']).toString(),
      employeeNo: (json['employeeNo'] ?? json['EmployeeNo']).toString(),
      departmentId: (json['departmentId'] ?? json['DepartmentId'])?.toString(),
      positionId: (json['positionId'] ?? json['PositionId'])?.toString(),
      positionName: (json['positionName'] ?? json['PositionName'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      profileImageUrl:
          (json['profileImageUrl'] ?? json['ProfileImageUrl'])?.toString(),
      status: (json['status'] ?? json['Status']).toString(),
      jobsStartDateUtc: jobsStartDateValue != null
          ? DateTime.parse(jobsStartDateValue.toString())
          : null,
      jobsEndDateUtc: jobsEndDateValue != null
          ? DateTime.parse(jobsEndDateValue.toString())
          : null,
      createdAtUtc: DateTime.parse(createdAtValue.toString()),
      updatedAtUtc: updatedAtValue != null
          ? DateTime.parse(updatedAtValue.toString())
          : null,
      deletedAtUtc: deletedAtValue != null
          ? DateTime.parse(deletedAtValue.toString())
          : null,
      userId: (json['userId'] ?? json['UserId'] ?? '').toString(),
    );
  }
}

class HRLargeLeaveResponseList {
  final List<HRLeaveResponse> allLeaves;
  final List<HRLeaveResponse> pendingLeaves;
  final List<HRLeaveResponse> approvedLeaves;
  final List<HRLeaveResponse> rejectedLeaves;

  HRLargeLeaveResponseList({
    required this.allLeaves,
    required this.pendingLeaves,
    required this.approvedLeaves,
    required this.rejectedLeaves,
  });

  factory HRLargeLeaveResponseList.fromJson(Map<String, dynamic> json) {
    return HRLargeLeaveResponseList(
      allLeaves: (json['allLeaves'] as List<dynamic>)
          .map((e) => HRLeaveResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingLeaves: (json['pendingLeaves'] as List<dynamic>)
          .map((e) => HRLeaveResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      approvedLeaves: (json['approvedLeaves'] as List<dynamic>)
          .map((e) => HRLeaveResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      rejectedLeaves: (json['rejectedLeaves'] as List<dynamic>)
          .map((e) => HRLeaveResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HRLeaveResponse {
  final String id;
  final String tenantId;
  final String branchId;
  final String departmentId;
  final String employeeId;
  final String employeeFullName;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;
  final String status;
  final String? approvedByUserId;
  final DateTime? approvedAtUtc;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  HRLeaveResponse({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.departmentId,
    required this.employeeId,
    required this.employeeFullName,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    this.approvedByUserId,
    this.approvedAtUtc,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  factory HRLeaveResponse.fromJson(Map<String, dynamic> json) {
    return HRLeaveResponse(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId']).toString(),
      departmentId: (json['departmentId'] ?? json['DepartmentId']).toString(),
      employeeId: (json['employeeId'] ?? json['EmployeeId']).toString(),
      employeeFullName:
          (json['employeeFullName'] ?? json['EmployeeFullName']).toString(),
      startDate:
          DateTime.parse((json['startDate'] ?? json['StartDate']).toString()),
      endDate: DateTime.parse((json['endDate'] ?? json['EndDate']).toString()),
      type: (json['type'] ?? json['Type']).toString(),
      reason: (json['reason'] ?? json['Reason']).toString(),
      status: (json['status'] ?? json['Status']).toString(),
      approvedByUserId:
          (json['approvedByUserId'] ?? json['ApprovedByUserId'])?.toString(),
      approvedAtUtc: json['approvedAtUtc'] != null
          ? DateTime.parse(json['approvedAtUtc'].toString())
          : null,
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
      updatedAtUtc: json['updatedAtUtc'] != null
          ? DateTime.parse(json['updatedAtUtc'].toString())
          : null,
    );
  }
}

class HRLeaveCreateRequest {
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;

  HRLeaveCreateRequest({
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'type': type,
      'reason': reason,
    };
  }
}

class HRLeaveDecideRequest {
  final String leaveId;
  final String status; // "approved" or "rejected"

  HRLeaveDecideRequest({
    required this.leaveId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'LeaveId': leaveId,
      'Status': status,
    };
  }
}

class HRPositionResponse {
  final String id;
  final String tenantId;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  HRPositionResponse({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  factory HRPositionResponse.fromJson(Map<String, dynamic> json) {
    return HRPositionResponse(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      name: (json['name'] ?? json['Name']).toString(),
      description: (json['description'] ?? json['Description']).toString(),
      isActive: (json['isActive'] ?? json['IsActive']) as bool,
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
      updatedAtUtc: json['updatedAtUtc'] != null
          ? DateTime.parse(json['updatedAtUtc'].toString())
          : null,
    );
  }
}

class HRCreatePositionRequest {
  final String name;
  final String? description;
  final bool? isActive;

  HRCreatePositionRequest({
    required this.name,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}

class HREmployeeDetailResponse {
  final String id;
  final String tenantId;
  final String branchId;
  final String employeeNo;
  final String fullName;
  final String? departmentId;
  final String? positionId;
  final String? positionName;
  final String? userId;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime? jobsStartDateUtc;
  final DateTime? jobsEndDateUtc;
  final String status;
  final List<HREmployeeDetailLeave> employeeLeaves;
  final List<HREmployeeDetailAdvance> employeeAdvances;
  final List<HREmployeeDetailRecord> disciplineEmployeeRecords;
  final List<HREmployeeDetailRecord> rewardEmployeeRecords;
  final List<HREmployeeDetailSalary> employeeSalaries;

  HREmployeeDetailResponse({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.employeeNo,
    required this.fullName,
    this.departmentId,
    this.positionId,
    this.positionName,
    this.userId,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.jobsStartDateUtc,
    this.jobsEndDateUtc,
    required this.status,
    required this.employeeLeaves,
    required this.employeeAdvances,
    required this.disciplineEmployeeRecords,
    required this.rewardEmployeeRecords,
    required this.employeeSalaries,
  });

  factory HREmployeeDetailResponse.fromJson(Map<String, dynamic> json) {
    return HREmployeeDetailResponse(
      id: (json['id'] ?? json['Id']).toString(),
      tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
      branchId: (json['branchId'] ?? json['BranchId']).toString(),
      employeeNo: (json['employeeNo'] ?? json['EmployeeNo']).toString(),
      fullName: (json['fullName'] ?? json['FullName']).toString(),
      departmentId: (json['departmentId'] ?? json['DepartmentId'])?.toString(),
      positionId: (json['positionId'] ?? json['PositionId'])?.toString(),
      positionName: (json['positionName'] ?? json['PositionName'])?.toString(),
      userId: (json['userId'] ?? json['UserId'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      profileImageUrl:
          (json['profileImageUrl'] ?? json['ProfileImageUrl'])?.toString(),
      jobsStartDateUtc: _parseNullableDate(
          json['jobsStartDateUtc'] ?? json['JobsStartDateUtc']),
      jobsEndDateUtc:
          _parseNullableDate(json['jobsEndDateUtc'] ?? json['JobsEndDateUtc']),
      status: (json['status'] ?? json['Status']).toString(),
      employeeLeaves: ((json['employeeLeaves'] ?? json['EmployeeLeaves'])
                  as List<dynamic>? ??
              const [])
          .map((e) => HREmployeeDetailLeave.fromJson(e as Map<String, dynamic>))
          .toList(),
      employeeAdvances: ((json['employeeAdvances'] ?? json['EmployeeAdvances'])
                  as List<dynamic>? ??
              const [])
          .map((e) =>
              HREmployeeDetailAdvance.fromJson(e as Map<String, dynamic>))
          .toList(),
      disciplineEmployeeRecords: ((json['disciplineEmployeeRecords'] ??
                  json['DisciplineEmployeeRecords']) as List<dynamic>? ??
              const [])
          .map(
              (e) => HREmployeeDetailRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewardEmployeeRecords: ((json['rewardEmployeeRecords'] ??
                  json['RewardEmployeeRecords']) as List<dynamic>? ??
              const [])
          .map(
              (e) => HREmployeeDetailRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      employeeSalaries: ((json['employeeSalaries'] ?? json['EmployeeSalaries'])
                  as List<dynamic>? ??
              const [])
          .map(
              (e) => HREmployeeDetailSalary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HREmployeeDetailLeave {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  HREmployeeDetailLeave({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  factory HREmployeeDetailLeave.fromJson(Map<String, dynamic> json) {
    return HREmployeeDetailLeave(
      id: (json['id'] ?? json['Id']).toString(),
      startDate:
          DateTime.parse((json['startDate'] ?? json['StartDate']).toString()),
      endDate: DateTime.parse((json['endDate'] ?? json['EndDate']).toString()),
      status: (json['status'] ?? json['Status']).toString(),
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
      updatedAtUtc:
          _parseNullableDate(json['updatedAtUtc'] ?? json['UpdatedAtUtc']),
    );
  }
}

class HREmployeeDetailAdvance {
  final String id;
  final num amount;
  final String status;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  HREmployeeDetailAdvance({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  factory HREmployeeDetailAdvance.fromJson(Map<String, dynamic> json) {
    return HREmployeeDetailAdvance(
      id: (json['id'] ?? json['Id']).toString(),
      amount: (json['amount'] ?? json['Amount']) as num? ?? 0,
      status: (json['status'] ?? json['Status']).toString(),
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
      updatedAtUtc:
          _parseNullableDate(json['updatedAtUtc'] ?? json['UpdatedAtUtc']),
    );
  }
}

class HREmployeeDetailRecord {
  final String id;
  final String description;
  final DateTime createdAtUtc;

  HREmployeeDetailRecord({
    required this.id,
    required this.description,
    required this.createdAtUtc,
  });

  factory HREmployeeDetailRecord.fromJson(Map<String, dynamic> json) {
    return HREmployeeDetailRecord(
      id: (json['id'] ?? json['Id']).toString(),
      description: (json['description'] ?? json['Description']).toString(),
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
    );
  }
}

class HREmployeeDetailSalary {
  final String id;
  final num netSalary;
  final DateTime createdAtUtc;

  HREmployeeDetailSalary({
    required this.id,
    required this.netSalary,
    required this.createdAtUtc,
  });

  factory HREmployeeDetailSalary.fromJson(Map<String, dynamic> json) {
    return HREmployeeDetailSalary(
      id: (json['id'] ?? json['Id']).toString(),
      netSalary: (json['netSalary'] ?? json['NetSalary']) as num? ?? 0,
      createdAtUtc: DateTime.parse(
          (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
    );
  }
}

DateTime? _parseNullableDate(dynamic value) {
  if (value == null) return null;
  return DateTime.parse(value.toString());
}
