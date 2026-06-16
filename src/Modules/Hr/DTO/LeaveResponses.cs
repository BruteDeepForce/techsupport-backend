using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record LeaveResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid DepartmentId,
    Guid EmployeeId,
    string EmployeeFullName,
    DateTime StartDate,
    DateTime EndDate,
    LeaveType Type,
    string Reason,
    LeaveStatus Status,
    Guid? ApprovedByUserId,
    DateTime? ApprovedAtUtc,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record LargeLeaveResponseList(
    IReadOnlyCollection<LeaveResponse> AllLeaves,
    IReadOnlyCollection<LeaveResponse> PendingLeaves,
    IReadOnlyCollection<LeaveResponse> ApprovedLeaves,
    IReadOnlyCollection<LeaveResponse> RejectedLeaves
);
