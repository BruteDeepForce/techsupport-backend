using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record AttendanceResponse(
    Guid? Id,
    Guid TenantId,
    Guid BranchId,
    Guid EmployeeId,
    Guid ShiftAssignmentId,
    DateTime ShiftDate,
    DateTime PlannedStartTimeUtc,
    DateTime PlannedEndTimeUtc,
    DateTime? CheckInTimeUtc,
    DateTime? CheckOutTimeUtc,
    AttendanceStatus Status,
    DateTime? CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record AttendanceLatenessResponse(
    Guid AttendanceId,
    Guid EmployeeId,
    DateTime ShiftDate,
    DateTime PlannedStartTimeUtc,
    DateTime? CheckInTimeUtc,
    bool IsLate,
    int LateByMinutes);
