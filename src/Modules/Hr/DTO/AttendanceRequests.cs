namespace Modules.HR.DTO;

public sealed record CreateAttendanceCheckInRequest(
    Guid? BranchId,
    Guid ShiftAssignmentId,
    Guid UserId
);
public sealed record CreateAttendanceCheckOutRequest(
    Guid UserId,
    Guid ShiftAssignmentId,
    DateTime? CheckOutTimeUtc);
