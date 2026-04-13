namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianAccountProvisioned(
    Guid CorrelationId,
    Guid AppUserId,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string Email,
    string? PhoneNumber,
    DateTimeOffset OccurredAtUtc);
