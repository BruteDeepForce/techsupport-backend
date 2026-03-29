namespace TechSupport.Technician.Contracts.Events;

/// <summary>
/// Published by Technician module when a technician updates the status of a work item.
/// Operation module consumes this, persists the new status, and then publishes OperationStatusChanged.
/// </summary>
public sealed record TechnicianOperationStatusChanged(
    Guid OperationId,
    Guid TenantId,
    Guid? BranchId,
    Guid TechnicianUserId,
    string TechnicianInfo,
    string NewStatus,
    DateTimeOffset OccurredAtUtc);
