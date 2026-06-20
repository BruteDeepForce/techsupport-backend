using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record CreateAdvanceRequest(
    Guid BranchId,
    Guid DepartmentId,
    Guid EmployeeId,
    bool isFutureAdvance,
    decimal TaksitSayisi,
    decimal Amount,
    string Reason);

public sealed record DecideAdvanceRequest(
    AdvanceStatus Status,
    Guid? ApprovedByUserId);

public sealed record UpdateAdvanceRequest(
    decimal? Amount,
    string? Reason,
    Guid? DepartmentId);

public sealed record CreateAdvanceSettingsRequest(
    Guid? BranchId,
    decimal MaxAdvanceAmountPerPerson,
    int MaxAdvanceCountPerYear,
    bool AllowFutureAdvances);

public sealed record UpdateAdvanceSettingsRequest(
    Guid? BranchId,
    decimal? MaxAdvanceAmountPerPerson,
    int? MaxAdvanceCountPerYear,
    bool? AllowFutureAdvances);
