using TechSupport.Operation.Contracts.Events;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public sealed class OperationReportSetService : IOperationReportSetService
{
    private readonly ReportSetStore _store;

    public OperationReportSetService(ReportSetStore store)
    {
        _store = store;
    }

    public async Task HandleOperationCreatedAsync(OperationCreated message, CancellationToken ct)
    {
        await _store.UpsertTenantSummaryAsync(
            message.TenantId,
            totalCustomersDelta: 0,
            totalOperationsDelta: 1,
            completedOperationsDelta: 0,
            failedOperationsDelta: 0,
            deliveredOperationsDelta: 0,
            openOperationsDelta: 1,
            ct);

        if (message.BranchId.HasValue)
        {
            await _store.UpsertBranchSummaryAsync(
                message.TenantId,
                message.BranchId.Value,
                totalCustomersDelta: 0,
                totalOperationsDelta: 1,
                completedOperationsDelta: 0,
                failedOperationsDelta: 0,
                deliveredOperationsDelta: 0,
                openOperationsDelta: 1,
                ct);
        }

        var day = DateOnly.FromDateTime(message.OccurredAtUtc.UtcDateTime);
        var month = new DateOnly(message.OccurredAtUtc.UtcDateTime.Year, message.OccurredAtUtc.UtcDateTime.Month, 1);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OperationCreatedCount, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OpenOperationCount, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OperationCreatedCount, ReportPeriodType.Daily, day, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OpenOperationCount, ReportPeriodType.Daily, day, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OperationCreatedCount, ReportPeriodType.Monthly, month, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OpenOperationCount, ReportPeriodType.Monthly, month, 1, ct);
    }

    public Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(tenantId, branchId, occurredAtUtc, ReportMetricType.OperationCompletedCount, ct);

    public Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(tenantId, branchId, occurredAtUtc, ReportMetricType.OperationDeliveredCount, ct);

    public Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(tenantId, branchId, occurredAtUtc, ReportMetricType.OperationFailedCount, ct);

    private async Task ApplyTerminalOperationTransitionAsync(
        Guid tenantId,
        Guid? branchId,
        DateTimeOffset occurredAtUtc,
        ReportMetricType terminalMetricType,
        CancellationToken ct)
    {
        var completedDelta = terminalMetricType == ReportMetricType.OperationCompletedCount ? 1 : 0;
        var failedDelta = terminalMetricType == ReportMetricType.OperationFailedCount ? 1 : 0;
        var deliveredDelta = terminalMetricType == ReportMetricType.OperationDeliveredCount ? 1 : 0;

        await _store.UpsertTenantSummaryAsync(
            tenantId,
            totalCustomersDelta: 0,
            totalOperationsDelta: 0,
            completedOperationsDelta: completedDelta,
            failedOperationsDelta: failedDelta,
            deliveredOperationsDelta: deliveredDelta,
            openOperationsDelta: -1,
            ct);

        if (branchId.HasValue)
        {
            await _store.UpsertBranchSummaryAsync(
                tenantId,
                branchId.Value,
                totalCustomersDelta: 0,
                totalOperationsDelta: 0,
                completedOperationsDelta: completedDelta,
                failedOperationsDelta: failedDelta,
                deliveredOperationsDelta: deliveredDelta,
                openOperationsDelta: -1,
                ct);
        }

        var day = DateOnly.FromDateTime(occurredAtUtc.UtcDateTime);
        await _store.IncrementMetricAsync(tenantId, branchId, terminalMetricType, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OpenOperationCount, ReportPeriodType.AllTime, null, -1, ct);
        await _store.IncrementMetricAsync(tenantId, branchId, terminalMetricType, ReportPeriodType.Daily, day, 1, ct);
        await _store.IncrementMetricAsync(tenantId, branchId, ReportMetricType.OpenOperationCount, ReportPeriodType.Daily, day, -1, ct);
    }
}
