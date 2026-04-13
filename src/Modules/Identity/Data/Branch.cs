namespace TechSupport.Identity.Data;

public class Branch
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }
    public Tenant Tenant { get; set; } = default!;

    public string Name { get; set; } = string.Empty;
}
