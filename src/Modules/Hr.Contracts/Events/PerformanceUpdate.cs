namespace TechSupport.Hr.Contracts.Events;

public sealed record PerformanceUpdate(
    Guid TenantId,
    Guid? BranchId,
    Guid EmployeeId,
    int Year,
    int Month,
    int TotalAssignedTasksDelta = 0,
    int TotalCompletedTasksDelta = 0,
    int TotalPendingTasksDelta = 0,
    int TotalOverdueTasksDelta = 0,
    int TotalCompletedOnTimeDelta = 0,
    int TotalCompletedLateDelta = 0,
    int RewardCountDelta = 0,
    int PenaltyCountDelta = 0,
    int LeaveCountDelta = 0,
    int ShiftAttendanceCountDelta = 0,
    int NotJoinedShiftCountDelta = 0,
    int OvertimeCountDelta = 0,
    DateTimeOffset? OccurredAtUtc = null);
