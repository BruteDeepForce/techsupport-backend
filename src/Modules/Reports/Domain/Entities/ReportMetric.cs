using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Domain.Entities;

public sealed class ReportMetric
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public ReportMetricType MetricType { get; set; }
    public ReportPeriodType PeriodType { get; set; } = ReportPeriodType.AllTime;
    public DateOnly? PeriodDate { get; set; }
    public long Value { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
