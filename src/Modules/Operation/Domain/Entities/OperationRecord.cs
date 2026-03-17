namespace TechSupport.Operation.Domain.Entities;

public sealed class OperationRecord
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public Guid CustomerId { get; set; }
    public Guid DeviceId { get; set; }

    public Guid? FieldTechnicianUserId { get; set; }
    // Optional link back to originating Ticket (one-to-one, nullable)
    public Guid? TicketId { get; set; }
    public Ticket? Ticket { get; set; }

    public Guid CreatedByUserId { get; set; }

    public OperationStatus Status { get; set; } = OperationStatus.Created;
    public OperationPriority Priority { get; set; } = OperationPriority.Normal;

    //! public OperationType Type { get; set; } = new OperationType(); ileri süreçte eklenecek.

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? InternalNote { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? AssignedAtUtc { get; set; }
    public DateTimeOffset? LastStatusChangedAtUtc { get; set; }
    public DateTimeOffset? DeliveredAtUtc { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public DateTimeOffset? ClosedAtUtc { get; set; }
    public bool IsClosed { get; set; }
}
public enum OperationStatus
{
    Created,
    Diagnosing,
    WaitingForApproval,
    Repairing,
    Testing,
    Completed,
    Delivered
}
public enum OperationPriority
{
    Normal,
    High,
    Urgent
}

// public class OperationType
// {
//     public Guid Id { get; set; }
//     public Guid TenantId { get; set; }
//     public string Name { get; set; } = string.Empty;
// }
