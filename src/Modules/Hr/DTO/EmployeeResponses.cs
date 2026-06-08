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
