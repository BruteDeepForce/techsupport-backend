namespace TechSupport.Operation.Contracts.Events;

public sealed record TicketConverted(Guid TicketId, Guid OperationId, Guid TenantId, DateTimeOffset OccurredAtUtc);
