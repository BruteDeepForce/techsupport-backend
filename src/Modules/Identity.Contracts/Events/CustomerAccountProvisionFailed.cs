namespace TechSupport.Identity.Contracts.Events;

public sealed record CustomerAccountProvisionFailed(
    Guid CorrelationId,
    string Email,
    string Reason,
    DateTimeOffset OccurredAtUtc);