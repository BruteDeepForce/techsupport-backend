namespace TechSupport.Operation.DTO;

public sealed record ResponseTicket(Guid Id, Guid TenantId, Guid? BranchId, Guid CustomerId, Guid? DeviceId, string Title, string Description, string Priority, string Status, DateTimeOffset CreatedAtUtc, Guid? ConvertedOperationId);
