using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record CreateAdvanceRequest(
    Guid BranchId,
    Guid DepartmentId,
    Guid EmployeeId,
    decimal Amount,
    string Reason);

public sealed record DecideAdvanceRequest(
    AdvanceStatus Status,
    Guid? ApprovedByUserId);

public sealed record UpdateAdvanceRequest(
    decimal? Amount,
    string? Reason,
    Guid? DepartmentId);
