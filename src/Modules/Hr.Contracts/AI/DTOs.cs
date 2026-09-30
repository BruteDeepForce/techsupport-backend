namespace TechSupport.Hr.Contracts.AI;

/// <summary>
/// AI tarafına çalışan bilgisini taşır.
/// </summary>
public sealed record EmployeeInfoResponse(
    Guid EmployeeId,
    string EmployeeNo,
    string FullName,
    string? DepartmentName,
    string? PositionName,
    string Status,
    string? Email,
    string? Phone);

/// <summary>
/// AI tarafına izin bilgisini taşır.
/// </summary>
public sealed record LeaveInfoResponse(
    Guid LeaveId,
    Guid EmployeeId,
    string? EmployeeName,
    string? DepartmentName,
    string LeaveType,
    string Status,
    DateTime StartDate,
    DateTime EndDate,
    string? Reason);

/// <summary>
/// AI tarafına avans bilgisini taşır.
/// </summary>
public sealed record AdvanceInfoResponse(
    Guid AdvanceId,
    Guid EmployeeId,
    string? EmployeeName,
    string? DepartmentName,
    decimal Amount,
    string Status,
    string? Reason,
    DateTime CreatedAtUtc);

/// <summary>
/// AI tarafına çalışan performans raporunu taşır.
/// </summary>
public sealed record EmployeePerformanceInfoResponse(
    Guid EmployeeId,
    string? EmployeeName,
    string? DepartmentName,
    int Year,
    int Month,
    int TotalAssignedTasks,
    int TotalCompletedTasks,
    int TotalPendingTasks,
    int TotalOverdueTasks,
    int RewardCount,
    int PenaltyCount,
    int LeaveCount,
    int NotJoinedShiftCount);

/// <summary>
/// AI tarafına tenant/branch seviyesinde insan kaynakları özetini taşır.
/// </summary>
public sealed record HrSummaryResponse(
    int TotalEmployeeCount,
    int ActiveEmployeeCount,
    int OnLeaveEmployeeCount,
    int PendingLeaveCount,
    decimal PendingAdvanceAmount,
    decimal TotalAdvanceAmount);