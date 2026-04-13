namespace TechSupport.Customer.Domain.Entities;

public sealed class Customer
{
    public Guid Id { get; set; }
    public Guid? AppUserId { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;

    // Navigation to join table; keeps relation explicit and queryable
    public ICollection<CustomerDevice> Devices { get; set; } = new List<CustomerDevice>();
}
