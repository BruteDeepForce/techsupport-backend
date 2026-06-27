using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record CreateLeaveRequest(
    Guid? BranchId,
    Guid? DepartmentId,
    Guid EmployeeId,
    Guid? LeaveDeductionId,
    DateTime StartDate,
    DateTime EndDate,
    LeaveType Type,
    string Reason);

public sealed record CreateLeaveRequestEmployee(
    Guid? BranchId,
    Guid? DepartmentId,
    Guid? LeaveDeductionId,
    DateTime StartDate,
    DateTime EndDate,
    LeaveType Type,
    string Reason);

public sealed record DecideLeaveRequest(
    Guid LeaveId,
    LeaveStatus Status,
    Guid? ApprovedByUserId);

public sealed record UpdateLeaveRequest(
    Guid? BranchId,
    Guid? DepartmentId,
    Guid EmployeeId,
    DateTime? StartDate,
    DateTime? EndDate,
    LeaveType? Type,
    LeaveStatus? Status,
    Guid? LeaveDeductionId,
    string? Reason);
