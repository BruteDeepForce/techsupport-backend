namespace TechSupport.Customer.Domain.Entities;


public sealed class CustomerDevice
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public Guid CustomerId { get; set; }
    public Guid DeviceId { get; set; }
    public string? Brand { get; set; }
    public string? Model { get; set; }
    public string? SerialNumber { get; set; }
    public string? BarcodeNumber { get; set; }
    public string? ProblemDescription { get; set; }
    public string? Status { get; set; }
    public bool IsActive { get; set; } = true;
    public int? GuaranteePeriod { get; set; }
    public DateTimeOffset? WarrantyStartAtUtc { get; set; }
    public DateTimeOffset? WarrantyEndAtUtc { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; set; }
    public DateTime? DeletedAtUtc { get; set; }

    public Customer? Customer { get; set; }
}
    
