namespace Modules.HR.DTO;

public sealed record CreateAttendanceCheckInRequest(
    Guid BranchId,
    Guid EmployeeId,
    Guid ShiftAssignmentId,
    DateTime? CheckInTimeUtc);

public sealed record CreateAttendanceCheckOutRequest(
    DateTime? CheckOutTimeUtc);
