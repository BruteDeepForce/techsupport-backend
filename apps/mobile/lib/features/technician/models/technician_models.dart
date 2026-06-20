class Technician {
  Technician({
    required this.userId,
    required this.tenantId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.pictureUrl,
    this.specializations,
    this.isActive,
  });

  final String userId;
  final String tenantId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? pictureUrl;
  final List<String>? specializations;
  final bool? isActive;

  // Backend now uses TechnicianId == UserId. Keep a convenience alias.
  String get id => userId;

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        userId: (json['userId'] ?? json['UserId'] ?? json['id'] ?? json['Id'])
                ?.toString() ??
            '',
        tenantId: (json['tenantId'] ?? json['TenantId'])?.toString() ?? '',
        name: (json['name'] ?? json['Name'] ?? json['firstName'])?.toString() ??
            '',
        email: (json['email'] ?? json['Email'])?.toString() ?? '',
        phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
        pictureUrl: (json['pictureUrl'] ?? json['PictureUrl'])?.toString(),
        specializations:
            (json['specializations'] ?? json['Specializations']) is List
                ? (json['specializations'] ?? json['Specializations'])
                    .map((e) => e.toString())
                    .toList()
                    .cast<String>()
                : null,
        isActive: json['isActive'] ?? json['IsActive'],
      );
}

class Experts {
  Experts({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Experts.fromJson(Map<String, dynamic> json) => Experts(
        id: (json['id'] ?? json['Id'])?.toString() ?? '',
        name: (json['name'] ??
                    json['Name'] ??
                    json['expertiseName'] ??
                    json['ExpertiseName'])
                ?.toString() ??
            '',
      );
}

class ShiftTemplateModel {
  ShiftTemplateModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isNightShift,
    required this.isActive,
    this.description,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final String id;
  final String tenantId;
  final String branchId;
  final String name;
  final Duration startTime;
  final Duration endTime;
  final bool isNightShift;
  final bool isActive;
  final String? description;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory ShiftTemplateModel.fromJson(Map<String, dynamic> json) =>
      ShiftTemplateModel(
        id: (json['id'] ?? json['Id']).toString(),
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        branchId: (json['branchId'] ?? json['BranchId']).toString(),
        name: (json['name'] ?? json['Name']).toString(),
        startTime:
            _parseDuration((json['startTime'] ?? json['StartTime']).toString()),
        endTime:
            _parseDuration((json['endTime'] ?? json['EndTime']).toString()),
        isNightShift:
            (json['isNightShift'] ?? json['IsNightShift']) as bool? ?? false,
        isActive: (json['isActive'] ?? json['IsActive']) as bool? ?? false,
        description: (json['description'] ?? json['Description'])?.toString(),
        createdAtUtc: DateTime.parse(
            (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
        updatedAtUtc: (json['updatedAtUtc'] ?? json['UpdatedAtUtc']) != null
            ? DateTime.parse(
                (json['updatedAtUtc'] ?? json['UpdatedAtUtc']).toString())
            : null,
      );
}

class CreateShiftTemplatePayload {
  CreateShiftTemplatePayload({
    required this.branchId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isNightShift,
    required this.isActive,
    this.description,
  });

  final String branchId;
  final String name;
  final Duration startTime;
  final Duration endTime;
  final bool isNightShift;
  final bool isActive;
  final String? description;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'name': name,
        'startTime': _durationToTimeSpan(startTime),
        'endTime': _durationToTimeSpan(endTime),
        'isNightShift': isNightShift,
        'isActive': isActive,
        'description': description,
      };
}

class ShiftAssignmentModel {
  ShiftAssignmentModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.employeeId,
    required this.shiftTemplateId,
    required this.shiftDate,
    required this.plannedStartTimeUtc,
    required this.plannedEndTimeUtc,
    this.actualStartTimeUtc,
    this.actualEndTimeUtc,
    required this.status,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final String id;
  final String tenantId;
  final String branchId;
  final String employeeId;
  final String shiftTemplateId;
  final DateTime shiftDate;
  final DateTime plannedStartTimeUtc;
  final DateTime plannedEndTimeUtc;
  final DateTime? actualStartTimeUtc;
  final DateTime? actualEndTimeUtc;
  final String status;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory ShiftAssignmentModel.fromJson(Map<String, dynamic> json) =>
      ShiftAssignmentModel(
        id: (json['id'] ?? json['Id']).toString(),
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        branchId: (json['branchId'] ?? json['BranchId']).toString(),
        employeeId: (json['employeeId'] ?? json['EmployeeId']).toString(),
        shiftTemplateId:
            (json['shiftTemplateId'] ?? json['ShiftTemplateId']).toString(),
        shiftDate:
            DateTime.parse((json['shiftDate'] ?? json['ShiftDate']).toString()),
        plannedStartTimeUtc: DateTime.parse(
            (json['plannedStartTimeUtc'] ?? json['PlannedStartTimeUtc'])
                .toString()),
        plannedEndTimeUtc: DateTime.parse(
            (json['plannedEndTimeUtc'] ?? json['PlannedEndTimeUtc'])
                .toString()),
        actualStartTimeUtc:
            (json['actualStartTimeUtc'] ?? json['ActualStartTimeUtc']) != null
                ? DateTime.parse(
                    (json['actualStartTimeUtc'] ?? json['ActualStartTimeUtc'])
                        .toString())
                : null,
        actualEndTimeUtc:
            (json['actualEndTimeUtc'] ?? json['ActualEndTimeUtc']) != null
                ? DateTime.parse(
                    (json['actualEndTimeUtc'] ?? json['ActualEndTimeUtc'])
                        .toString())
                : null,
        status: (json['status'] ?? json['Status']).toString(),
        createdAtUtc: DateTime.parse(
            (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString()),
        updatedAtUtc: (json['updatedAtUtc'] ?? json['UpdatedAtUtc']) != null
            ? DateTime.parse(
                (json['updatedAtUtc'] ?? json['UpdatedAtUtc']).toString())
            : null,
      );
}

class CreateShiftAssignmentPayload {
  CreateShiftAssignmentPayload({
    this.branchId,
    required this.employeeId,
    required this.shiftTemplateId,
    required this.shiftDate,
    required this.plannedStartTimeUtc,
    required this.plannedEndTimeUtc,
  });

  final String? branchId;
  final String employeeId;
  final String shiftTemplateId;
  final DateTime shiftDate;
  final DateTime plannedStartTimeUtc;
  final DateTime plannedEndTimeUtc;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'employeeId': employeeId,
        'shiftTemplateId': shiftTemplateId,
        'shiftDate': shiftDate.toUtc().toIso8601String(),
        'plannedStartTimeUtc': plannedStartTimeUtc.toUtc().toIso8601String(),
        'plannedEndTimeUtc': plannedEndTimeUtc.toUtc().toIso8601String(),
      };
}

class BlockShiftTimePayload {
  BlockShiftTimePayload({
    required this.startTimeUtc,
    required this.endTimeUtc,
  });

  final DateTime startTimeUtc;
  final DateTime endTimeUtc;

  Map<String, dynamic> toJson() => {
        'startTimeUtc': startTimeUtc.toUtc().toIso8601String(),
        'endTimeUtc': endTimeUtc.toUtc().toIso8601String(),
      };
}

class CreateBlockShiftAssignmentPayload {
  CreateBlockShiftAssignmentPayload({
    this.branchId,
    required this.employeeId,
    required this.plannedTimesUtc,
  });

  final String? branchId;
  final String employeeId;
  final List<BlockShiftTimePayload> plannedTimesUtc;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'employeeId': employeeId,
        'plannedTimesUtc': plannedTimesUtc.map((x) => x.toJson()).toList(),
      };
}

class CreateAttendanceCheckInPayload {
  CreateAttendanceCheckInPayload({
    this.branchId,
    required this.shiftAssignmentId,
  });

  final String? branchId;
  final String shiftAssignmentId;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'shiftAssignmentId': shiftAssignmentId,
        'userId': '00000000-0000-0000-0000-000000000000',
      };
}

class CreateAttendanceCheckOutPayload {
  CreateAttendanceCheckOutPayload({
    this.checkOutTimeUtc,
    this.shiftAssignmentId,
  });

  final DateTime? checkOutTimeUtc;
  final String? shiftAssignmentId;

  Map<String, dynamic> toJson() => {
        'userId': '00000000-0000-0000-0000-000000000000',
        'checkOutTimeUtc': checkOutTimeUtc?.toUtc().toIso8601String(),
        'shiftAssignmentId': shiftAssignmentId,
      };
}

class BlockShiftAssignmentResponse {
  BlockShiftAssignmentResponse({
    required this.tenantId,
    required this.employeeId,
    required this.startTimeUtc,
    required this.endTimeUtc,
  });

  final String tenantId;
  final String employeeId;
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;

  factory BlockShiftAssignmentResponse.fromJson(Map<String, dynamic> json) =>
      BlockShiftAssignmentResponse(
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        employeeId: (json['employeeId'] ?? json['EmployeeId']).toString(),
        startTimeUtc: DateTime.parse(
          (json['startTimeUtc'] ?? json['StartTimeUtc']).toString(),
        ),
        endTimeUtc: DateTime.parse(
          (json['endTimeUtc'] ?? json['EndTimeUtc']).toString(),
        ),
      );
}

class TechnicianMyShiftModel {
  TechnicianMyShiftModel({
    this.id,
    required this.tenantId,
    required this.branchId,
    required this.employeeId,
    required this.shiftAssignmentId,
    required this.shiftDate,
    required this.plannedStartTimeUtc,
    required this.plannedEndTimeUtc,
    this.checkInTimeUtc,
    this.checkOutTimeUtc,
    required this.status,
    this.createdAtUtc,
    this.updatedAtUtc,
  });

  final String? id;
  final String tenantId;
  final String branchId;
  final String employeeId;
  final String shiftAssignmentId;
  final DateTime shiftDate;
  final DateTime plannedStartTimeUtc;
  final DateTime plannedEndTimeUtc;
  final DateTime? checkInTimeUtc;
  final DateTime? checkOutTimeUtc;
  final String status;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TechnicianMyShiftModel.fromJson(Map<String, dynamic> json) =>
      TechnicianMyShiftModel(
        id: (json['id'] ?? json['Id'])?.toString(),
        tenantId: (json['tenantId'] ?? json['TenantId']).toString(),
        branchId: (json['branchId'] ?? json['BranchId']).toString(),
        employeeId: (json['employeeId'] ?? json['EmployeeId']).toString(),
        shiftAssignmentId:
            (json['shiftAssignmentId'] ?? json['ShiftAssignmentId']).toString(),
        shiftDate:
            DateTime.parse((json['shiftDate'] ?? json['ShiftDate']).toString()),
        plannedStartTimeUtc: DateTime.parse(
          (json['plannedStartTimeUtc'] ?? json['PlannedStartTimeUtc'])
              .toString(),
        ),
        plannedEndTimeUtc: DateTime.parse(
          (json['plannedEndTimeUtc'] ?? json['PlannedEndTimeUtc']).toString(),
        ),
        checkInTimeUtc: (json['checkInTimeUtc'] ?? json['CheckInTimeUtc']) !=
                null
            ? DateTime.parse(
                (json['checkInTimeUtc'] ?? json['CheckInTimeUtc']).toString(),
              )
            : null,
        checkOutTimeUtc: (json['checkOutTimeUtc'] ?? json['CheckOutTimeUtc']) !=
                null
            ? DateTime.parse(
                (json['checkOutTimeUtc'] ?? json['CheckOutTimeUtc']).toString(),
              )
            : null,
        status: (json['status'] ?? json['Status']).toString(),
        createdAtUtc: (json['createdAtUtc'] ?? json['CreatedAtUtc']) != null
            ? DateTime.parse(
                (json['createdAtUtc'] ?? json['CreatedAtUtc']).toString(),
              )
            : null,
        updatedAtUtc: (json['updatedAtUtc'] ?? json['UpdatedAtUtc']) != null
            ? DateTime.parse(
                (json['updatedAtUtc'] ?? json['UpdatedAtUtc']).toString(),
              )
            : null,
      );
}

Duration _parseDuration(String value) {
  final parts = value.split(':');
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final seconds = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String _durationToTimeSpan(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
