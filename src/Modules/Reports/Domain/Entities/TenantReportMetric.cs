using TechSupport.Reports.Contracts;

namespace TechSupport.Reports.Domain.Entities;

public sealed class TenantReportMetric
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public TenantReportMetricType MetricType { get; set; }
    public TenantReportPeriodType PeriodType { get; set; }
    public DateOnly PeriodStart { get; set; }
    public long Value { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
