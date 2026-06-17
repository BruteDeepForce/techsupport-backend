namespace Modules.HR.DTO;

public sealed record CreateRewardRequest(
    Guid? BranchId,
    string Description,
    decimal RewardAmount);

public sealed record UpdateRewardRequest(
    string? Description,
    decimal? RewardAmount);

public sealed record CreateRewardEmployeeRecordRequest(
    Guid? BranchId,
    Guid EmployeeId,
    Guid RewardId,
    string Description,
    DateTime RewardDate);

public sealed record UpdateRewardEmployeeRecordRequest(
    Guid? RewardId,
    string? Description,
    DateTime? RewardDate);
