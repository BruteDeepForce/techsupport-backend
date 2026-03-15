namespace TechSupport.Technician.Domain.Entities;

public sealed class Technician
{
    public Guid Id { get; set; }
    public Guid? AppUserId { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}
