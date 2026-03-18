using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Npgsql;
using Reports.Domain.Entities;
using Reports.Domain.Enums;
using TechSupport.Reports.Data;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public sealed class ReportSetStore
{
    private readonly ReportDbContext _db;

    public ReportSetStore(ReportDbContext db)
    {
        _db = db;
    }

    public Task<IDbContextTransaction> BeginTransactionAsync(CancellationToken ct)
        => _db.Database.BeginTransactionAsync(ct);

    public Task<bool> TryRegisterProcessedEventAsync(string eventName, Guid? messageId, Guid? correlationId, Guid tenantId, CancellationToken ct)
        => TryRegisterProcessedEventInternalAsync(eventName, messageId, correlationId, tenantId, ct);

    public Task IncrementMetricAsync(Guid tenantId, Guid? branchId, ReportMetricType metricType, ReportPeriodType periodType, DateOnly? periodDate, long delta, CancellationToken ct)
        => IncrementMetricInternalAsync(tenantId, branchId, metricType, periodType, periodDate, delta, ct);

    public Task UpsertTenantSummaryAsync(Guid tenantId, int totalCustomersDelta, int totalOperationsDelta, int completedOperationsDelta, int failedOperationsDelta, int deliveredOperationsDelta, int openOperationsDelta, CancellationToken ct)
        => UpsertTenantSummaryInternalAsync(tenantId, totalCustomersDelta, totalOperationsDelta, completedOperationsDelta, failedOperationsDelta, deliveredOperationsDelta, openOperationsDelta, ct);

    public Task UpsertBranchSummaryAsync(Guid tenantId, Guid branchId, int totalCustomersDelta, int totalOperationsDelta, int completedOperationsDelta, int failedOperationsDelta, int deliveredOperationsDelta, int openOperationsDelta, CancellationToken ct)
        => UpsertBranchSummaryInternalAsync(tenantId, branchId, totalCustomersDelta, totalOperationsDelta, completedOperationsDelta, failedOperationsDelta, deliveredOperationsDelta, openOperationsDelta, ct);

    public async Task CreateTenantSummaryAsync(Guid tenantId, string tenantName, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var entity = new TenantReportSummary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            TenantName = tenantName,
            TotalCustomers = 0,
            TotalOperations = 0,
            CompletedOperations = 0,
            FailedOperations = 0,
            DeliveredOperations = 0,
            OpenOperations = 0,
            CreatedAtUtc = occurredAtUtc,
            UpdatedAtUtc = occurredAtUtc
        };

        var entry = await _db.TenantReportSummaries.AddAsync(entity, ct);
        //! entry kullanabilir miyiz?

        await _db.SaveChangesAsync(ct);
    }
    public async Task UpsertTechnicianSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        Guid technicianUserId,
        string name,
        string email,
        string? phoneNumber,
        DateTimeOffset occurredAtUtc,
        CancellationToken ct)
        => await UpsertTechnicianSummaryInternalAsync(tenantId, branchId, technicianUserId, name, email, phoneNumber, occurredAtUtc, ct);
    public async Task IncrementTechnicianMetricAsync(
        Guid tenantId,
        Guid? branchId,
        Guid technicianUserId,
        ReportMetricType metricType,
        ReportPeriodType periodType,
        DateOnly? periodDate,
        long delta,
        CancellationToken ct)
        => await IncrementTechnicianMetricInternalAsync(tenantId, branchId, technicianUserId, metricType, periodType, periodDate, delta, ct);

    public async Task TechnicianWorksSetAsync (Guid tenantId, Guid technicianId, string operationDescription, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var work = new TechnicianWork
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            TechnicianId = technicianId,
            OperationDescription = operationDescription,
            Status = WorkStatus.Assigned,
            AssignedAtUtc = occurredAtUtc,
        };
        await _db.TechnicianWorks.AddAsync(work);

        await _db.SaveChangesAsync(ct);
    }
    private async Task IncrementMetricInternalAsync( //! olay burada teknisyen userid var ise metrikler ekleniyor.
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

        var metric = new ReportMetric
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
        };

        await AddWithUniqueRetryAsync(metric, async ct2 =>
        {
            await _db.ReportMetrics
                .Where(x =>
                    x.TenantId == tenantId &&
                    x.BranchId == branchId &&
                    x.MetricType == metricType &&
                    x.PeriodType == periodType &&
                    x.PeriodDate == periodDate)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.Value, x => x.Value + delta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);
        }, ct);
    }

    private async Task IncrementTechnicianMetricInternalAsync(
        Guid tenantId,
        Guid? branchId,
        Guid technicianUserId,
        ReportMetricType metricType,
        ReportPeriodType periodType,
        DateOnly? periodDate,
        long delta,
        CancellationToken ct)
    {
        var updated = await _db.TechnicianReportMetrics
            .Where(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.TechnicianUserId == technicianUserId &&
                x.MetricType == metricType &&
                x.PeriodType == periodType &&
                x.PeriodDate == periodDate)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.Value, x => x.Value + delta)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
            return;

        var metric = new TechnicianReportMetric
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            TechnicianUserId = technicianUserId,
            MetricType = metricType,
            PeriodType = periodType,
            PeriodDate = periodDate,
            Value = delta,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        };

        await AddWithUniqueRetryAsync(metric, async ct2 =>
        {
            await _db.TechnicianReportMetrics
                .Where(x =>
                    x.TenantId == tenantId &&
                    x.BranchId == branchId &&
                    x.TechnicianUserId == technicianUserId &&
                    x.MetricType == metricType &&
                    x.PeriodType == periodType &&
                    x.PeriodDate == periodDate)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.Value, x => x.Value + delta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);
        }, ct);
    }

    private async Task<bool> TryRegisterProcessedEventInternalAsync(string eventName, Guid? messageId, Guid? correlationId, Guid tenantId, CancellationToken ct)
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

    private async Task UpsertTenantSummaryInternalAsync(
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
                await ClampTenantOpenOperationsAsync(tenantId, ct);

            return;
        }

        var entity = new TenantReportSummary
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
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await _db.TenantReportSummaries
                .Where(x => x.TenantId == tenantId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                    .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                    .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                    .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                    .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                    .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);

            if (openOperationsDelta < 0)
                await ClampTenantOpenOperationsAsync(tenantId, ct2);
        }, ct);
    }

    private async Task UpsertBranchSummaryInternalAsync(
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
                await ClampBranchOpenOperationsAsync(tenantId, branchId, ct);

            return;
        }

        var entity = new BranchReportSummary
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
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await _db.BranchReportSummaries
                .Where(x => x.TenantId == tenantId && x.BranchId == branchId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.TotalCustomers, x => x.TotalCustomers + totalCustomersDelta)
                    .SetProperty(x => x.TotalOperations, x => x.TotalOperations + totalOperationsDelta)
                    .SetProperty(x => x.CompletedOperations, x => x.CompletedOperations + completedOperationsDelta)
                    .SetProperty(x => x.FailedOperations, x => x.FailedOperations + failedOperationsDelta)
                    .SetProperty(x => x.DeliveredOperations, x => x.DeliveredOperations + deliveredOperationsDelta)
                    .SetProperty(x => x.OpenOperations, x => x.OpenOperations + openOperationsDelta)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);

            if (openOperationsDelta < 0)
                await ClampBranchOpenOperationsAsync(tenantId, branchId, ct2);
        }, ct);
    }

    private async Task UpsertTechnicianSummaryInternalAsync(
        Guid tenantId,
        Guid? branchId,
        Guid technicianUserId,
        string Name,
        string email,
        string? phoneNumber,
        DateTimeOffset occurredAtUtc,
        CancellationToken ct)
    {
        var updated = await _db.TechnicianReportSummaries
            .Where(x => x.TenantId == tenantId && x.TechnicianUserId == technicianUserId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.BranchId, _ => branchId)
                .SetProperty(x => x.Name, _ => Name)
                .SetProperty(x => x.Email, _ => email)
                .SetProperty(x => x.PhoneNumber, _ => phoneNumber)
                .SetProperty(x => x.LastProfileUpdateAtUtc, _ => occurredAtUtc)
                .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct);

        if (updated > 0)
            return;

        var entity = new TechnicianReportSummary
        { //! alt metodla beraber incelenmeli. retry mekanizması...
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            TechnicianUserId = technicianUserId,
            Name = Name,
            Email = email,
            PhoneNumber = phoneNumber,
            LastProfileUpdateAtUtc = occurredAtUtc,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            UpdatedAtUtc = DateTimeOffset.UtcNow
        };

        await AddWithUniqueRetryAsync(entity, async ct2 =>
        {
            await _db.TechnicianReportSummaries
                .Where(x => x.TenantId == tenantId && x.TechnicianUserId == technicianUserId)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(x => x.BranchId, _ => branchId)
                    .SetProperty(x => x.Name, _ => Name)
                    .SetProperty(x => x.Email, _ => email)
                    .SetProperty(x => x.PhoneNumber, _ => phoneNumber)
                    .SetProperty(x => x.LastProfileUpdateAtUtc, _ => occurredAtUtc)
                    .SetProperty(x => x.UpdatedAtUtc, _ => DateTimeOffset.UtcNow), ct2);
        }, ct);
    }

    private async Task AddWithUniqueRetryAsync<T>(T entity, Func<CancellationToken, Task> onUniqueConflict, CancellationToken ct) where T : class
    {
        //!burayı incelemem lazım
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
        => ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation };
}
