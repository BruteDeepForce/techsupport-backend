namespace TechSupport.User.Domain.Entities;

public sealed class UserProfile
{
    public Guid Id { get; set; }
    public Guid AppUserId { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // admin/customer/technician
    public bool IsActive { get; set; } = true;
}
