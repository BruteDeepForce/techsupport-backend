namespace TechSupport.Identity.Contracts.Events;

public sealed record CustomerAccountProvisioned(
    Guid CorrelationId,
    Guid AppUserId,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string Email,
    string? PhoneNumber,
    DateTimeOffset OccurredAtUtc);