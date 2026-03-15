namespace TechSupport.Operation.Contracts.Events;

public sealed record OperationCreated(Guid OperationId, Guid TenantId, Guid? BranchId, Guid CustomerId, Guid DeviceId, Guid CreatedBy, Guid? FieldTechnicianUserId, string Title, string Description, DateTimeOffset OccurredAtUtc);
