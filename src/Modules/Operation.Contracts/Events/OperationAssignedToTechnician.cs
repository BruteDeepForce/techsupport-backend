namespace TechSupport.Operation.Contracts.Events;

/// <summary>
/// Published by Operation module when an operation is assigned to a field technician.
/// Reports consumes this for technician-related reporting.
/// </summary>
public sealed record OperationAssignedToTechnician(
    Guid OperationId,
    Guid TenantId,
    Guid? BranchId,
    Guid TechnicianUserId,
    DateTimeOffset OccurredAtUtc);
