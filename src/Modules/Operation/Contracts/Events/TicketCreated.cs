namespace TechSupport.Operation.Contracts.Events;

public sealed record TicketCreated(Guid TicketId, Guid TenantId, Guid? BranchId, Guid CustomerId, Guid? DeviceId, string Title, string Description, DateTimeOffset OccurredAtUtc);
