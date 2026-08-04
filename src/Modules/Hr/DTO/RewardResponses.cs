namespace Modules.HR.DTO;

public sealed record RewardResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string Description,
    decimal RewardAmount,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);

public sealed record RewardEmployeeRecordResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid EmployeeId,
    Guid RewardId,
    string Description,
    DateTime RewardDate,
    DateTime CreatedAtUtc);
