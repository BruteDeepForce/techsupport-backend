namespace Modules.HR.DTO;

public sealed record CreateEmployeeRequest(
    string? EmployeeNo,
    string FullName,
    Guid? BranchId,
    Guid? DepartmentId,
    Guid? PositionId,
    Guid? UserId,
    string? Email,
    string? Phone,
    string? ProfileImageUrl,
    DateTime? JobsStartDateUtc,
    DateTime? JobsEndDateUtc);

public sealed record UpdateEmployeeRequest(
    string? FullName,
    Guid? DepartmentId,
    Guid? PositionId,
    Guid? UserId,
    string? Email,
    string? Phone,
    string? ProfileImageUrl,
    DateTime? JobsStartDateUtc,
    DateTime? JobsEndDateUtc,
    bool? IsActive);
