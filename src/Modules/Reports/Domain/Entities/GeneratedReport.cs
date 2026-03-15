using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Domain.Entities;

public sealed class GeneratedReport
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ContentJson { get; set; }
    public ReportPeriodType PeriodType { get; set; } = ReportPeriodType.AllTime;
    public DateOnly? PeriodDate { get; set; }
    public DateTimeOffset GeneratedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }
}
