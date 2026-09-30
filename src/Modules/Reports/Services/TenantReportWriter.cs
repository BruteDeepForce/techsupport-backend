using Microsoft.EntityFrameworkCore;
using Npgsql;
using TechSupport.Reports.Contracts;
using TechSupport.Reports.Data;
using TechSupport.Reports.Domain.Entities;
using ContractPlannedOperationSnapshot = TechSupport.Reports.Contracts.PlannedOperationSnapshot;
using DomainPlannedOperationSnapshot = TechSupport.Reports.Domain.Entities.PlannedOperationSnapshot;

namespace TechSupport.Reports.Services;

public sealed class TenantReportWriter : ITenantReportWriter
{
    private readonly ReportDbContext _db;

    public TenantReportWriter(ReportDbContext db)
    {
        _db = db;
    }

    public async Task EnsureTenantSummaryAsync(
        Guid tenantId,
        string tenantName,
        DateTimeOffset occurredAtUtc,
        CancellationToken ct = default)
    {
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        var normalizedTenantName = tenantName.Trim();

        var updated = await _db.TenantReportSummaries
            .Where(x => x.TenantId == tenantId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.TenantName, _ => normalizedTenantName)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
            return;

        var entity = new TenantReportSummary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            TenantName = normalizedTenantName,
            CreatedAtUtc = occurredAtUtc,
            UpdatedAtUtc = occurredAtUtc
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await _db.TenantReportSummaries
                .Where(x => x.TenantId == tenantId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.TenantName, _ => normalizedTenantName)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);
        }, ct);
    }

    public async Task IncrementSummaryAsync(
        Guid tenantId,
        TenantReportSummaryDelta delta,
        CancellationToken ct = default)
    {
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        var updated = await _db.TenantReportSummaries
            .Where(x => x.TenantId == tenantId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + delta.TotalCustomers)
                .SetProperty(x => x.TotalOperations, x => x.TotalOperations + delta.TotalOperations)
                .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + delta.CompletedOperations)
                .SetProperty(x => x.FailedOperations, x => x.FailedOperations + delta.FailedOperations)
                .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + delta.DeliveredOperations)
                .SetProperty(x => x.OpenOperations, x => x.OpenOperations + delta.OpenOperations)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
        {
            await ClampSummaryCountersAsync(tenantId, ct);
            return;
        }

        var entity = new TenantReportSummary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            TotalCustomers = Math.Max(0, delta.TotalCustomers),
            TotalOperations = Math.Max(0, delta.TotalOperations),
            CompletedOperations = Math.Max(0, delta.CompletedOperations),
            FailedOperations = Math.Max(0, delta.FailedOperations),
            DeliveredOperations = Math.Max(0, delta.DeliveredOperations),
            OpenOperations = Math.Max(0, delta.OpenOperations),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await IncrementSummaryAsync(tenantId, delta, ct2);
        }, ct);
    }

    public Task IncrementPeriodMetricAsync(
        Guid tenantId,
        TenantReportMetricType metricType,
        TenantReportPeriodType periodType,
        DateTimeOffset occurredAtUtc,
        long delta = 1,
        CancellationToken ct = default)
    {
        var periodStart = GetPeriodStart(periodType, occurredAtUtc);
        return IncrementMetricValueAsync(tenantId, metricType, periodType, periodStart, delta, ct);
    }

    private async Task IncrementMetricValueAsync(
        Guid tenantId,
        TenantReportMetricType metricType,
        TenantReportPeriodType periodType,
        DateOnly periodStart,
        long delta,
        CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        var updated = await _db.TenantReportMetrics
            .Where(x =>
                x.TenantId == tenantId &&
                x.MetricType == metricType &&
                x.PeriodType == periodType &&
                x.PeriodStart == periodStart)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.Value, x => x.Value + delta)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
        {
            await ClampMetricAsync(tenantId, metricType, periodType, periodStart, ct);
            return;
        }

        var entity = new TenantReportMetric
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            MetricType = metricType,
            PeriodType = periodType,
            PeriodStart = periodStart,
            Value = Math.Max(0, delta),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await IncrementMetricValueAsync(tenantId, metricType, periodType, periodStart, delta, ct2);
        }, ct);
    }

    private static DateOnly GetPeriodStart(TenantReportPeriodType periodType, DateTimeOffset occurredAtUtc)
    {
        var utc = occurredAtUtc.UtcDateTime;

        return periodType switch
        {
            TenantReportPeriodType.Daily => DateOnly.FromDateTime(utc.Date),
            TenantReportPeriodType.Monthly => new DateOnly(utc.Year, utc.Month, 1),
            TenantReportPeriodType.Yearly => new DateOnly(utc.Year, 1, 1),
            TenantReportPeriodType.Weekly => DateOnly.FromDateTime(StartOfIsoWeek(utc.Date)),
            _ => throw new ArgumentOutOfRangeException(nameof(periodType), periodType, "Unsupported report period type.")
        };
    }

    private static DateTime StartOfIsoWeek(DateTime date)
    {
        var diff = ((int)date.DayOfWeek + 6) % 7;
        return date.AddDays(-diff);
    }

    private async Task ClampSummaryCountersAsync(Guid tenantId, CancellationToken ct)
    {
        await _db.TenantReportSummaries
            .Where(x => x.TenantId == tenantId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers < 0 ? 0 : x.TotalCustomers)
                .SetProperty(x => x.TotalOperations, x => x.TotalOperations < 0 ? 0 : x.TotalOperations)
                .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations < 0 ? 0 : x.CompletedOperations)
                .SetProperty(x => x.FailedOperations, x => x.FailedOperations < 0 ? 0 : x.FailedOperations)
                .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations < 0 ? 0 : x.DeliveredOperations)
                .SetProperty(x => x.OpenOperations, x => x.OpenOperations < 0 ? 0 : x.OpenOperations), ct);
    }

    private async Task ClampMetricAsync(
        Guid tenantId,
        TenantReportMetricType metricType,
        TenantReportPeriodType periodType,
        DateOnly periodStart,
        CancellationToken ct)
    {
        await _db.TenantReportMetrics
            .Where(x =>
                x.TenantId == tenantId &&
                x.MetricType == metricType &&
                x.PeriodType == periodType &&
                x.PeriodStart == periodStart &&
                x.Value < 0)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.Value, _ => 0)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);
    }

    private async Task AddWithUniqueRetryAsync<T>(
        T entity,
        Func<CancellationToken, Task> onUniqueConflict,
        CancellationToken ct) where T : class
    {
        _db.Set<T>().Add(entity);

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsUniqueViolation(ex))
        {
            _db.ChangeTracker.Clear();
            await onUniqueConflict(ct);
        }
    }

    private static bool IsUniqueViolation(DbUpdateException ex)
        => ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation };

    public async Task<bool> WritePlannedOperationAsync(ContractPlannedOperationSnapshot plannedOperation, CancellationToken ct)
    {
        if (plannedOperation.TenantId == Guid.Empty ||
            plannedOperation.OperationId == Guid.Empty ||
            plannedOperation.ToTechnicianUserId == Guid.Empty)
        {
            return false;
        }

        var entity = new DomainPlannedOperationSnapshot
        {
            Id = plannedOperation.Id,
            TenantId = plannedOperation.TenantId,
            BranchId = plannedOperation.BranchId,
            ScheduledAtUtc = plannedOperation.ScheduledAtUtc,
            ToTechnicianUserId = plannedOperation.ToTechnicianUserId,
            TechnicianFullName = plannedOperation.TechnicianFullName,
            CustomerId = plannedOperation.CustomerId,
            CustomerName = plannedOperation.CustomerName,
            Title = plannedOperation.Title,
            Description = plannedOperation.Description,
            OperationId = plannedOperation.OperationId
        };

        await _db.PlannedOperationSnapshots.AddAsync(entity, ct);
        var result = await _db.SaveChangesAsync(ct);
        return result > 0;
    }
}
