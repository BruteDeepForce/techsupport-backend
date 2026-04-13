namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianAccountProvisionFailed(
    Guid CorrelationId,
    string Email,
    string Reason,
    DateTimeOffset OccurredAtUtc);
