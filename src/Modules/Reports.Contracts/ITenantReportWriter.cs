namespace TechSupport.Reports.Contracts;

public interface ITenantReportWriter
{
    Task EnsureTenantSummaryAsync(
        Guid tenantId,
        string tenantName,
        DateTimeOffset occurredAtUtc,
        CancellationToken ct = default);

    Task IncrementSummaryAsync(
        Guid tenantId,
        TenantReportSummaryDelta delta,
        CancellationToken ct = default);

    Task IncrementPeriodMetricAsync(
        Guid tenantId,
        TenantReportMetricType metricType,
        TenantReportPeriodType periodType,
        DateTimeOffset occurredAtUtc,
        long delta = 1,
        CancellationToken ct = default);
}
