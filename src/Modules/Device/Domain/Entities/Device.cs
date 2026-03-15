namespace TechSupport.Device.Domain.Entities;

public sealed class Devices
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public string ProblemDescription { get; set; } = string.Empty;
    public string Brand { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public string SerialNumber { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTimeOffset? UpdatedAtUtc { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? DeactivatedAtUtc { get; set; }
}
