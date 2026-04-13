namespace TechSupport.Identity.Data;

public class Tenant
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public ICollection<Branch> Branches { get; set; } = new List<Branch>();
}
