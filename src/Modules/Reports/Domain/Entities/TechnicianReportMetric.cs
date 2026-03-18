using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Domain.Entities;

/// <summary>
/// Per-technician metric time series.
/// </summary>
public sealed class TechnicianReportMetric
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid TechnicianUserId { get; set; }

    public string OperationDescription { get; set; } = string.Empty;  //!burası atanan işin içeriği olacak.

    public ReportMetricType MetricType { get; set; }
    public ReportPeriodType PeriodType { get; set; } = ReportPeriodType.AllTime;
    public DateOnly? PeriodDate { get; set; }
    public long Value { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
