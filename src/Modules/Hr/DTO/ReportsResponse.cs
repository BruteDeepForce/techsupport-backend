using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record LeavesDTO(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid DepartmentId,
    Guid EmployeeId,
    DateTime StartDate,
    DateTime EndDate,
    LeaveType Type,
    string Reason,
    LeaveStatus Status,
    Guid? ApprovedByUserId,
    DateTime? ApprovedAtUtc,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record AdvanceDTO(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid DepartmentId,
    Guid EmployeeId,
    decimal Amount,
    string Reason,
    AdvanceStatus Status,
    Guid? ApprovedByUserId,
    DateTime? ApprovedAtUtc,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record MiniReportPagination(
    int Page,
    int Limit,
    int TotalLeaves,
    int TotalAdvances,
    bool HasNextLeaves,
    bool HasNextAdvances);

public sealed record LeaveAndAdvanceResponse(
    List<LeavesDTO> Leaves,
    List<AdvanceDTO> Advances,
    MiniReportPagination Pagination);