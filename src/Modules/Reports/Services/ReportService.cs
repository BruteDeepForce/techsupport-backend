using Microsoft.EntityFrameworkCore;
using Npgsql;
using TechSupport.Customer.Contracts.Events;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Reports.Data;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public sealed class ReportService : IReportService
{
    private readonly ReportDbContext _db;

    public ReportService(ReportDbContext db)
    {
        _db = db;
    }

    public async Task HandleCustomerCreatedAsync(CustomerCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _db.Database.BeginTransactionAsync(ct);

        if (!await TryRegisterProcessedEventAsync(nameof(CustomerCreated), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await UpsertTenantSummaryAsync(
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
            await UpsertBranchSummaryAsync(
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

        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.CustomerCreatedCount, ReportPeriodType.AllTime, null, 1, ct);
        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.CustomerCreatedCount, ReportPeriodType.Daily, DateOnly.FromDateTime(message.OccurredAtUtc.UtcDateTime), 1, ct);

        await tx.CommitAsync(ct);
    }

    public async Task HandleOperationCreatedAsync(OperationCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _db.Database.BeginTransactionAsync(ct);

        if (!await TryRegisterProcessedEventAsync(nameof(OperationCreated), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await UpsertTenantSummaryAsync(
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
            await UpsertBranchSummaryAsync(
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
        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OperationCreatedCount, ReportPeriodType.AllTime, null, 1, ct);
        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OpenOperationCount, ReportPeriodType.AllTime, null, 1, ct);
        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OperationCreatedCount, ReportPeriodType.Daily, day, 1, ct);
        await IncrementMetricAsync(message.TenantId, message.BranchId, ReportMetricType.OpenOperationCount, ReportPeriodType.Daily, day, 1, ct);

        await tx.CommitAsync(ct);
    }

    public Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationCompletedAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId, ReportMetricType.OperationCompletedCount,
            updateTenant: s => s.CompletedOperations += 1,
            updateBranch: s => s.CompletedOperations += 1,
            ct);

    public Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationDeliveredAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId, ReportMetricType.OperationDeliveredCount,
            updateTenant: s => s.DeliveredOperations += 1,
            updateBranch: s => s.DeliveredOperations += 1,
            ct);

    public Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationFailedAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId, ReportMetricType.OperationFailedCount,
            updateTenant: s => s.FailedOperations += 1,
            updateBranch: s => s.FailedOperations += 1,
            ct);

    private async Task ApplyTerminalOperationTransitionAsync(
        string eventName,
        Guid tenantId,
        Guid? branchId,
        DateTimeOffset occurredAtUtc,
        Guid? messageId,
        Guid? correlationId,
        ReportMetricType terminalMetricType,
        Action<TenantReportSummary> updateTenant,
        Action<BranchReportSummary> updateBranch,
        CancellationToken ct)
    {
        await using var tx = await _db.Database.BeginTransactionAsync(ct);

        if (!await TryRegisterProcessedEventAsync(eventName, messageId, correlationId, tenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        var tenantCompletedDelta = terminalMetricType == ReportMetricType.OperationCompletedCount ? 1 : 0;
        var tenantFailedDelta = terminalMetricType == ReportMetricType.OperationFailedCount ? 1 : 0;
        var tenantDeliveredDelta = terminalMetricType == ReportMetricType.OperationDeliveredCount ? 1 : 0;

        await UpsertTenantSummaryAsync(
            tenantId,
            totalCustomersDelta: 0,
            totalOperationsDelta: 0,
            completedOperationsDelta: tenantCompletedDelta,
            failedOperationsDelta: tenantFailedDelta,
            deliveredOperationsDelta: tenantDeliveredDelta,
            openOperationsDelta: -1,
            ct);

        if (branchId.HasValue)
        {
            await UpsertBranchSummaryAsync(
                tenantId,
                branchId.Value,
                totalCustomersDelta: 0,
                totalOperationsDelta: 0,
                completedOperationsDelta: tenantCompletedDelta,
                failedOperationsDelta: tenantFailedDelta,
                deliveredOperationsDelta: tenantDeliveredDelta,
                openOperationsDelta: -1,
                ct);
        }

        var day = DateOnly.FromDateTime(occurredAtUtc.UtcDateTime);
        await IncrementMetricAsync(tenantId, branchId, terminalMetricType, ReportPeriodType.AllTime, null, 1, ct);
        await IncrementMetricAsync(tenantId, branchId, ReportMetricType.OpenOperationCount, ReportPeriodType.AllTime, null, -1, ct);
        await IncrementMetricAsync(tenantId, branchId, terminalMetricType, ReportPeriodType.Daily, day, 1, ct);
        await IncrementMetricAsync(tenantId, branchId, ReportMetricType.OpenOperationCount, ReportPeriodType.Daily, day, -1, ct);

        await tx.CommitAsync(ct);
    }

    private async Task IncrementMetricAsync(
        Guid tenantId,
        Guid? branchId,
        ReportMetricType metricType,
        ReportPeriodType periodType,
        DateOnly? periodDate,
        long delta,
        CancellationToken ct)
    {
        var updated = await _db.ReportMetrics
            .Where(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.MetricType == metricType &&
                x.PeriodType == periodType &&
                x.PeriodDate == periodDate)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.Value, x => x.Value + delta)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
            return;

        _db.ReportMetrics.Add(new ReportMetric
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            MetricType = metricType,
            PeriodType = periodType,
            PeriodDate = periodDate,
            Value = delta,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        });

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            _db.ChangeTracker.Clear();

            await _db.ReportMetrics
                .Where(x =>
                    x.TenantId == tenantId &&
                    x.BranchId == branchId &&
                    x.MetricType == metricType &&
                    x.PeriodType == periodType &&
                    x.PeriodDate == periodDate)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.Value, x => x.Value + delta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);
        }
    }

    private async Task<bool> TryRegisterProcessedEventAsync(string eventName, Guid? messageId, Guid? correlationId, Guid tenantId, CancellationToken ct)
    {
        if (!messageId.HasValue)
            return true;

        var exists = await _db.ProcessedReportEvents
            .AnyAsync(x => x.EventName == eventName && x.MessageId == messageId.Value, ct);

        if (exists)
            return false;

        _db.ProcessedReportEvents.Add(new ProcessedReportEvent
        {
            Id = Guid.NewGuid(),
            EventName = eventName,
            MessageId = messageId.Value,
            CorrelationId = correlationId,
            TenantId = tenantId,
            ProcessedAtUtc = DateTimeOffset.UtcNow
        });

        try
        {
            await _db.SaveChangesAsync(ct);
            return true;
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            _db.ChangeTracker.Clear();
            return false;
        }
    }

    private async Task UpsertTenantSummaryAsync(
        Guid tenantId,
        int totalCustomersDelta,
        int totalOperationsDelta,
        int completedOperationsDelta,
        int failedOperationsDelta,
        int deliveredOperationsDelta,
        int openOperationsDelta,
        CancellationToken ct)
    {
        var updated = await _db.TenantReportSummaries
            .Where(x => x.TenantId == tenantId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
        {
            if (openOperationsDelta < 0)
            {
                await ClampTenantOpenOperationsAsync(tenantId, ct);
            }

            return;
        }

        _db.TenantReportSummaries.Add(new TenantReportSummary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            TotalCustomers = totalCustomersDelta,
            TotalOperations = totalOperationsDelta,
            CompletedOperations = completedOperationsDelta,
            FailedOperations = failedOperationsDelta,
            DeliveredOperations = deliveredOperationsDelta,
            OpenOperations = Math.Max(0, openOperationsDelta),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        });

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            _db.ChangeTracker.Clear();  //bunu araştırcam daha çok

            await _db.TenantReportSummaries
                .Where(x => x.TenantId == tenantId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                    .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                    .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                    .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                    .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                    .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

            if (openOperationsDelta < 0)
            {
                await ClampTenantOpenOperationsAsync(tenantId, ct);
            }
        }
    }

    private async Task UpsertBranchSummaryAsync(
        Guid tenantId,
        Guid branchId,
        int totalCustomersDelta,
        int totalOperationsDelta,
        int completedOperationsDelta,
        int failedOperationsDelta,
        int deliveredOperationsDelta,
        int openOperationsDelta,
        CancellationToken ct)
    {
        var updated = await _db.BranchReportSummaries
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
        {
            if (openOperationsDelta < 0)
            {
                await ClampBranchOpenOperationsAsync(tenantId, branchId, ct);
            }

            return;
        }

        _db.BranchReportSummaries.Add(new BranchReportSummary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            TotalCustomers = totalCustomersDelta,
            TotalOperations = totalOperationsDelta,
            CompletedOperations = completedOperationsDelta,
            FailedOperations = failedOperationsDelta,
            DeliveredOperations = deliveredOperationsDelta,
            OpenOperations = Math.Max(0, openOperationsDelta),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        });

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            _db.ChangeTracker.Clear();

            await _db.BranchReportSummaries
                .Where(x => x.TenantId == tenantId && x.BranchId == branchId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                    .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                    .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                    .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                    .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                    .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

            if (openOperationsDelta < 0)
            {
                await ClampBranchOpenOperationsAsync(tenantId, branchId, ct);
            }
        }
    }

    private Task ClampTenantOpenOperationsAsync(Guid tenantId, CancellationToken ct)
    {
        return _db.TenantReportSummaries
            .Where(x => x.TenantId == tenantId && x.OpenOperations < 0)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.OpenOperations, _ => 0)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);
    }

    private Task ClampBranchOpenOperationsAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        return _db.BranchReportSummaries
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId && x.OpenOperations < 0)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.OpenOperations, _ => 0)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);
    }

    private static bool IsUniqueViolation(DbUpdateException ex)
    {
        return ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation };
    }
}