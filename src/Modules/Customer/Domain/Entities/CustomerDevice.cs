namespace TechSupport.Customer.Domain.Entities;

public sealed class CustomerDevice
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid CustomerId { get; set; }
    // DeviceId is stored as reference to the Device bounded-context
    public Guid DeviceId { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; set; } = null;
    public DateTime? DeletedAtUtc { get; set; } = null;
    // Navigation 
    public Customer? Customer { get; set; }
}
