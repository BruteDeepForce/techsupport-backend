namespace TechSupport.Operation.Contracts.Events;

/// <summary>
/// Published by Operation module after it persists an operation status change.
/// Reports consumes this to update metrics and summaries.
/// </summary>
public sealed record OperationStatusChanged(
    Guid OperationId,
    Guid TenantId,
    Guid? BranchId,
    string OldStatus,
    string NewStatus,
    DateTimeOffset OccurredAtUtc);
