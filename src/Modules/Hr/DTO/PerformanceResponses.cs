namespace Modules.HR.DTO;

public sealed record EmployeePerformanceReportResponse(
    Guid Id,
    Guid EmployeeId,
    Guid TenantId,
    Guid? BranchId,
    int Year,
    int Month,
    int TotalAssignedTasks,
    int TotalCompletedTasks,
    int TotalPendingTasks,
    int TotalOverdueTasks,
    int? TotalCompletedOnTime,
    int? TotalCompletedLate,
    int RewardCount,
    int PenaltyCount,
    int LeaveCount,
    int ShiftAttendanceCount,
    int NotJoinedShiftCount,
    int OvertimeCount);
