namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianHrEmployeeSyncRequested(
    Guid CorrelationId,
    Guid TechnicianId,
    Guid AppUserId,
    Guid TenantId,
    Guid? BranchId,
    string FullName,
    string Email,
    string? PhoneNumber,
    string? ProfileImageUrl,
    bool IsActive,
    DateTimeOffset? EmploymentStartDate,
    DateTimeOffset OccurredAtUtc);
