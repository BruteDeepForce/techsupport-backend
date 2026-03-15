namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianAccountProvisioned(
    Guid CorrelationId,
    Guid AppUserId,
    Guid TenantId,
    Guid? BranchId,
    string FirstName,
    string LastName,
    string Email,
    string? PhoneNumber,
    DateTimeOffset OccurredAtUtc);
