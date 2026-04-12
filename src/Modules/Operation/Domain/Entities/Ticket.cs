namespace TechSupport.Operation.Domain.Entities;

public enum TicketStatus
{
    Open,
    CreatedOperation,
    Repairing,
    Closed,
    Rejected
}

public sealed class Ticket
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public Guid CustomerId { get; set; }
    public Guid? DeviceId { get; set; }

    public string? CustomerName { get; set; }
    public Guid? OperationId { get; set; }
    public OperationRecord? Operation { get; set; }

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Priority Priority { get; set; } = Priority.Normal;

    public TicketStatus Status { get; set; } = TicketStatus.Open;

    public Guid? CreatedByUserId { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public ICollection<TicketAttachment>? Attachments { get; set; } = new List<TicketAttachment>();

}
public enum Priority
{
    Normal,
    High,
    Urgent
}


