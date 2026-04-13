namespace TechSupport.Customer.Contracts.Events;

public sealed record CustomerIdentityLinked(
    Guid CustomerId,
    Guid AppUserId,
    Guid CorrelationId,
    DateTimeOffset OccurredAtUtc);