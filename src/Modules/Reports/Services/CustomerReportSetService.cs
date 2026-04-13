using TechSupport.Customer.Contracts.Events;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public sealed class CustomerReportSetService : ICustomerReportSetService
{
    private readonly ReportSetStore _store;

    public CustomerReportSetService(ReportSetStore store)
    {
        _store = store;
    }

    public async Task HandleCustomerCreatedAsync(CustomerCreated message, CancellationToken ct)
    {
        await _store.UpsertTenantSummaryAsync(
            message.TenantId,
            totalCustomersDelta: 1,
            totalOperationsDelta: 0,
            completedOperationsDelta: 0,
            failedOperationsDelta: 0,
            deliveredOperationsDelta: 0,
            openOperationsDelta: 0,
            ct);

        if (message.BranchId.HasValue)
        {
            await _store.UpsertBranchSummaryAsync(
                message.TenantId,
                message.BranchId.Value,
                totalCustomersDelta: 1,
                totalOperationsDelta: 0,
                completedOperationsDelta: 0,
                failedOperationsDelta: 0,
                deliveredOperationsDelta: 0,
                openOperationsDelta: 0,
                ct);
        }

        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.CustomerCreatedCount, ReportPeriodType.AllTime, null, 1, ct);
        await _store.IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.CustomerCreatedCount, ReportPeriodType.Daily, DateOnly.FromDateTime(message.OccurredAtUtc.UtcDateTime), 1, ct);
    }
}
