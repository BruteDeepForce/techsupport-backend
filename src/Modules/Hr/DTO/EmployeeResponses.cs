using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record EmployeeResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string EmployeeNo,
    string FullName,
    Guid? DepartmentId,
    Guid? PositionId,
    string? PositionName,
    Guid? UserId,
    string? Email,
    string? Phone,
    string? ProfileImageUrl,
    EmployeeStatus Status,
    DateTime? JobsStartDateUtc,
    DateTime? JobsEndDateUtc,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc,
    DateTime? DeletedAtUtc);

public sealed record EmployeeDetailResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string EmployeeNo,
    string FullName,
    Guid? DepartmentId,
    Guid? PositionId,
    string? PositionName,
    Guid? UserId,
    string? Email,
    string? Phone,
    string? ProfileImageUrl,
    EmployeeStatus Status,
    DateTime? JobsStartDateUtc,
    DateTime? JobsEndDateUtc,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc,
    DateTime? DeletedAtUtc,
    List<LeaveResponse> EmployeeLeaves,
    List<AdvanceResponse> EmployeeAdvances,
    List<DisciplineEmployeeRecordResponse> DisciplineEmployeeRecords,
    List<RewardEmployeeRecordResponse> RewardEmployeeRecords,
    List<EmployeeSalaryResponse> EmployeeSalaries);

public sealed record EmployeeLargeDetailResponse(
    List<EmployeeResponse> Employees,
    int TotalCount,
    int ActiveCount,
    int PassiveCount,
    int EmployeesOnLeaveCount,
    int PendingLeavesCount,
    int EmployeesWithPendingAdvanceRequestsCount
);
