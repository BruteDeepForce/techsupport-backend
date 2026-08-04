using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record LeaveDeductionResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string Description,
    LeaveType? DeductionType,
    DeductionPeriodForCalculation? DeductionPeriod,
    decimal DeductionAmount,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
