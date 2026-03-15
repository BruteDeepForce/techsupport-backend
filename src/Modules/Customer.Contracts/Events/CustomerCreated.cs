namespace TechSupport.Customer.Contracts.Events;

public sealed record CustomerCreated(
    Guid CustomerId,
    Guid? AppUserId,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string Email,
    DateTimeOffset OccurredAtUtc);