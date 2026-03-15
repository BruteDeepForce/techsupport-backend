namespace TechSupport.Customer.Domain.Entities;


public sealed class CustomerDevice
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public Guid CustomerId { get; set; }
    public Guid DeviceId { get; set; }

    public int? DeviceGuaranteePeriod { get; private set; }
    public DateTime? DeviceGuaranteeStartDate { get; private set; }
    public DateTime? DeviceGuaranteeEndDate { get; private set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; set; }
    public DateTime? DeletedAtUtc { get; set; }

    public Customer? Customer { get; set; }

    // EF Core için gerekli
    public CustomerDevice() { }

    // Domain constructor
    public CustomerDevice(int deviceGuaranteePeriod, DateTime deviceGuaranteeStartDate)
    {
        DeviceGuaranteePeriod = deviceGuaranteePeriod;
        DeviceGuaranteeStartDate = deviceGuaranteeStartDate;
        DeviceGuaranteeEndDate = deviceGuaranteeStartDate.AddMonths(deviceGuaranteePeriod);
    }
}
    
