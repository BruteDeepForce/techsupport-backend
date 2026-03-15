namespace TechSupport.Reports.Services;

using TechSupport.Reports.Domain.Enums;

/// <summary>
/// Technician-focused reporting SET logic.
/// 
/// For now we keep it minimal (assignment events), and can grow metrics/tables later
/// without bloating the orchestrator.
/// </summary>
public sealed class TechnicianReportSetService : ITechnicianReportSetService
{
    private readonly ReportSetStore _store;

    public TechnicianReportSetService(ReportSetStore store)
    {
        _store = store;
    }

    public Task HandleOperationAssignedToTechnicianAsync(Guid tenantId, Guid? branchId, Guid technicianUserId, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var day = DateOnly.FromDateTime(occurredAtUtc.UtcDateTime);

        // Tenant/branch-level: how many assignments happened.
        // These are useful for dashboards without joining a technician dimension.
        return Task.WhenAll(
            _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OperationAssignedToTechnicianCount, ReportPeriodType.AllTime, null, 1, ct),
            _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OperationAssignedToTechnicianCount, ReportPeriodType.Daily, day, 1, ct),

            // Per-technician: assignment volume.
            _store.IncrementTechnicianMetricAsync(tenantId, branchId, technicianUserId, ReportMetricType.TechnicianAssignedOperationCount, ReportPeriodType.AllTime, null, 1, ct),
            _store.IncrementTechnicianMetricAsync(tenantId, branchId, technicianUserId, ReportMetricType.TechnicianAssignedOperationCount, ReportPeriodType.Daily, day, 1, ct)
        );
    }
}
