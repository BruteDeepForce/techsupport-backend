namespace TechSupport.Reports.Services;

using global::Reports.Domain.Entities;
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

    public async Task HandleOperationAssignedToTechnicianAsync(Guid tenantId, Guid? branchId, Guid technicianUserId, Guid operationId, string description, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var day = DateOnly.FromDateTime(occurredAtUtc.UtcDateTime);
        var month = new DateOnly(occurredAtUtc.UtcDateTime.Year, occurredAtUtc.UtcDateTime.Month, 1);

        // Tenant/branch-level: how many assignments happened.
        // These are useful for dashboards without joining a technician dimension.

        await _store.TechnicianWorksSetAsync(tenantId, technicianUserId, operationId, description, occurredAtUtc, ct);

        await _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OperationAssignedToTechnicianCount, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OperationAssignedToTechnicianCount, ReportPeriodType.Daily, day, 1, ct);
        await _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OperationAssignedToTechnicianCount, ReportPeriodType.Monthly, month, 1, ct);

        // Per-technician: assignment volume.
        await _store.IncrementTechnicianMetricAsync(tenantId, branchId, technicianUserId, ReportMetricType.TechnicianAssignedOperationCount, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementTechnicianMetricAsync(tenantId, branchId, technicianUserId, ReportMetricType.TechnicianAssignedOperationCount, ReportPeriodType.Daily, day, 1, ct);
        await _store.IncrementTechnicianMetricAsync(tenantId, branchId, technicianUserId, ReportMetricType.TechnicianAssignedOperationCount, ReportPeriodType.Monthly, month, 1, ct);
    }
}
