using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record CreateLeaveDeductionRequest(
    string Description,
    LeaveType? DeductionType,
    DeductionPeriodForCalculation? DeductionPeriod,
    decimal DeductionAmount);

public sealed record UpdateLeaveDeductionRequest(
    string? Description,
    LeaveType? DeductionType,
    DeductionPeriodForCalculation? DeductionPeriod,
    decimal? DeductionAmount);
