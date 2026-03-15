namespace TechSupport.Technician.Domain.Entities;

public sealed class TechnicianOperation
{
    public Guid Id { get; set; }
    public Guid OperationId { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public Guid CustomerId { get; set; }
    public Guid DeviceId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public Guid? AssignedTechnicianId { get; set; }
    public DateTimeOffset? AssignedAtUtc { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public TechnicianOperationStatus Status { get; set; } = TechnicianOperationStatus.Assigned;
}
public enum TechnicianOperationStatus
{
    Assigned,
    Accepted,
    Rejected,
    Completed
}
