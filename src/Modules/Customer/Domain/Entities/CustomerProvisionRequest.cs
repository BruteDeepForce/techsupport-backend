namespace TechSupport.Customer.Domain.Entities;

public sealed class CustomerProvisionRequest
{
    public Guid Id { get; set; }
    public Guid CorrelationId { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public ProvisioningStatus Status { get; set; } = ProvisioningStatus.Pending;
    public Guid? AppUserId { get; set; }
    public Guid? CustomerId { get; set; }
    public string? FailureReason { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? CompletedAtUtc { get; set; }
}

public enum ProvisioningStatus
{
    Pending = 0,
    Completed = 1,
    Failed = 2
}