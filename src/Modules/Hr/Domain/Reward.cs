namespace Modules.HR.Domain;

public class Reward
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal RewardAmount { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime UpdatedAtUtc { get; set; }

    public ICollection<RewardEmployeeRecord> RewardEmployeeRecords { get; set; } = new List<RewardEmployeeRecord>();
}
