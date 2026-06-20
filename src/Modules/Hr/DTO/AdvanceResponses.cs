using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record AdvanceResponse(
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

public sealed record AdvanceSettingsResponse(
    Guid Id,
    Guid TenantId,
    Guid? BranchId,
    decimal MaxAdvanceAmountPerPerson,
    int MaxAdvanceCountPerYear,
    bool AllowFutureAdvances,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);
