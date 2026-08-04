namespace Modules.HR.Domain;

public class RewardEmployeeRecord
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid EmployeeId { get; set; }
    public Employee Employee { get; set; } = null!;
    public Guid RewardId { get; set; }
    public Reward Reward { get; set; } = null!;
    public string Description { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime RewardDate { get; set; }
}
