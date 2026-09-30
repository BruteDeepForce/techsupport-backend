using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Reports.Contracts;

namespace TechSupport.Operation.Services;

public interface IOperationService
{
    Task<OperationRecord> CreateAsync(
        Guid tenantId,
        Guid? branchId,
        Guid createdBy,
        string TechnicianfuLLname,
        Guid customerId,
        Guid deviceId,
        Guid? toTechnician,
        string title,
        string description,
        string? internalNote,
        Guid? ticketId,
        OperationPriority priority,
        string? customerName,
        OperationType type,
        Guid? maintenanceTemplateId,
        DateTimeOffset? scheduledAtUtc,
        OperationFuture future,
        CancellationToken ct);
    Task<OperationRecord?> GetAsync(Guid tenantId, Guid operationId, CancellationToken ct);
    Task<IEnumerable<OperationRecord>> AdminGetAllAsync(Guid tenantId, CancellationToken ct);

    Task<IEnumerable<OperationRecord>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct);

    Task<IEnumerable<OperationRecord>> TechnicianGetAllAsync(Guid tenantId, Guid technicianId, CancellationToken ct);

    Task<OperationRecord> UpdateAsync(Guid tenantId, Guid operationId, Guid updatedBy, string title, string description, Guid? toTechnician, string? internalNote, CancellationToken ct);

    Task<OperationRecord> UpdateStatusAsync(Guid tenantId, Guid operationId, Guid updatedBy, string TechnicianInfo, string status, CancellationToken ct);
}

public sealed class OperationService : IOperationService
{
    private readonly OperationDbContext _db;
    private readonly IBus _bus;
    private readonly ITenantReportWriter _reports;

    private readonly IOperationPlanService _operationPlanService;

    public OperationService(OperationDbContext db, IBus bus, ITenantReportWriter reports, IOperationPlanService operationPlanService)
    {
        _db = db;
        _bus = bus;
        _reports = reports;
        _operationPlanService = operationPlanService;
    }

    public async Task<OperationRecord> CreateAsync(
        Guid tenantId,
        Guid? branchId,
        Guid createdBy,
        string TechnicianfuLLname,
        Guid customerId,
        Guid deviceId,
        Guid? toTechnician,
        string title,
        string description,
        string? internalNote,
        Guid? ticketId,
        OperationPriority priority,
        string? customerName,
        OperationType type,
        Guid? maintenanceTemplateId,
        DateTimeOffset? scheduledAtUtc,
        OperationFuture future,
        CancellationToken ct)
    {
        var opId = Guid.NewGuid();
        var op = new OperationRecord
        {
            Id = opId,
            TenantId = tenantId,
            BranchId = branchId,
            CustomerId = customerId,
            DeviceId = deviceId,
            CreatedByUserId = createdBy,
            FieldTechnicianUserId = toTechnician,
            TechnicianFullName = TechnicianfuLLname,
            TicketId = ticketId,
            CustomerFullName = customerName ?? string.Empty,
            Type = type,
            MaintenanceTemplateId = type == OperationType.Maintenance ? maintenanceTemplateId : null,
            Title = title,
            Description = description,
            Priority = priority,
            InternalNote = internalNote,
            Future = future,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            AssignedAtUtc = toTechnician.HasValue ? DateTimeOffset.UtcNow : null,
            LastStatusChangedAtUtc = DateTimeOffset.UtcNow
        };

        if (future == OperationFuture.Scheduled)
        {
            if (!scheduledAtUtc.HasValue)
                throw new InvalidOperationException("Scheduled operation requires a scheduled date.");

            if (!toTechnician.HasValue)
                throw new InvalidOperationException("Scheduled operation requires a technician.");

            var planOpGuid = Guid.NewGuid();
            op.PlannedOperation = new PlannedOperation
            {
                Id = planOpGuid,
                TenantId = tenantId,
                BranchId = branchId,
                OperationRecordId = opId,
                ScheduledAtUtc = scheduledAtUtc.Value,
                ToTechnicianUserId = toTechnician.Value,
                TechnicianFullName = TechnicianfuLLname,
                CustomerId = customerId,
                CustomerName = customerName ?? string.Empty,
                Title = title,
                Description = description
            };
        }

        await _db.Operations.AddAsync(op);
        await _db.SaveChangesAsync(ct);

        if (op.PlannedOperation is not null)
        {
            var plan = op.PlannedOperation;
            var result = await _operationPlanService.WritePlannedOperationSnapshotAsync(
                tenantId,
                branchId,
                plan.Id,
                plan.ScheduledAtUtc,
                plan.ToTechnicianUserId,
                plan.TechnicianFullName,
                plan.CustomerId,
                plan.CustomerName,
                plan.Title,
                plan.Description,
                opId,
                ct);
            if (!result)
            {
                _db.Operations.Remove(op);
                await _db.SaveChangesAsync(ct);
                throw new InvalidOperationException("Planned operation report snapshot could not be written.");
            }
        }

        var now = DateTimeOffset.UtcNow;
        await _reports.IncrementSummaryAsync(tenantId,new TenantReportSummaryDelta(TotalOperations: 1, OpenOperations: 1), ct);
        await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OperationCreated, now, 1, ct);
        await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OpenOperation, now, 1, ct);


        /// koşul teknisyenid var mı ??? 
        /// varsa teknisyen modülüne teknisyen operation assign et.
        ///  
        ///  
        //! sistemi değiştirdim.
        //! bir operasyon için teknisyenid yoksa sadece operasyon raporu oluşturuyor.
        //! teknisyenid varsa operasyon raporu oluşturuyor ve rapor modülünde teknisyene atanmış operasyon için metricler güncelleniyor
        //! ayrıca teknisyenid var ise teknisyen modülünde de teknisyene atanmış operasyon oluşturuluyor. 
        //! Böylece teknisyen modülü teknisyene atanmış operasyonları kendi veritabanında tutuyor ve operasyon modülüne bağımlılığı kalmıyor.
        await _bus.Publish(new OperationCreated(
            op.Id,
            op.TenantId,
            op.BranchId,
            op.CustomerId,
            op.DeviceId,
            op.CreatedByUserId,
            op.FieldTechnicianUserId,
            op.Title,
            op.Description,
            now), ct);
            //! teknisyen ataması varsa teknisyen modülüne de event publish edelim. 
            //! böylece teknisyen modülü teknisyene atanmış operasyonları kendi veritabanında tutabilir ve operasyon modülüne bağımlılığı kalmaz.
        if (toTechnician.HasValue)
        {
        await _bus.Publish(new OperationAssignedToTechnician(
            op.Id,
            op.TenantId,
            op.BranchId,
            op.FieldTechnicianUserId ?? Guid.Empty, //! saçma. teknistene assign etmiceksek niye pushluyoz
            op.CustomerId,
            op.DeviceId,
            op.Title,
            op.Description,
            op.Type.ToString(),
            now), ct);
        }
        //! operasyon oluşturulduktan sonra ai modülüne operasyonun oluşturulduğunu bildiriyoruz.
        await _bus.Publish(new OperationCreatedToAI
        {
            OperationId = op.Id,
            TenantId = op.TenantId,
            BranchId = op.BranchId ?? Guid.Empty,
            CustomerInfo = $"CustomerId: {op.CustomerId}",
            TechnicianInfo = TechnicianfuLLname,
            Title = op.Title,
            Description = op.Description,
            Status = op.Status.ToString(),
            CreatedAtUtc = op.CreatedAtUtc,
        }, ct);
        return op;
    }

    public async Task<OperationRecord?> GetAsync(Guid tenantId, Guid operationId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking()
            .Include(x => x.PlannedOperation)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId, ct);
    }
    public async Task<IEnumerable<OperationRecord>> AdminGetAllAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking()
            .Include(x => x.PlannedOperation)
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
    }

    public async Task<IEnumerable<OperationRecord>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking()
            .Include(x => x.PlannedOperation)
            .Where(x => x.TenantId == tenantId && x.CustomerId == customerId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
    }

    public async Task<IEnumerable<OperationRecord>> TechnicianGetAllAsync(Guid tenantId, Guid technicianId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking()
            .Include(x => x.PlannedOperation)
            .Where(x => x.TenantId == tenantId && x.FieldTechnicianUserId == technicianId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
    }

    public async Task<OperationRecord> UpdateAsync(Guid tenantId, Guid operationId, Guid updatedBy, string title, string description, Guid? toTechnician, string? internalNote, CancellationToken ct)
    {
        var op = await _db.Operations
            .Include(x => x.PlannedOperation)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId, ct);
        if (op == null) throw new InvalidOperationException("Operation not found");
        op.Title = title;
        op.Description = description;
        op.FieldTechnicianUserId = toTechnician;
        op.InternalNote = internalNote;
        op.UpdatedAtUtc = DateTimeOffset.UtcNow;

        if (toTechnician.HasValue)
        {
            op.AssignedAtUtc ??= DateTimeOffset.UtcNow;
        }

        //! burada publish çakalım ai modülüne.  assign var mı yok mu onu ayrıca düşünelim.

        await _db.SaveChangesAsync(ct);

        return op;
    }
    public async Task<OperationRecord> UpdateStatusAsync(Guid tenantId, Guid operationId, Guid updatedBy, string TechnicianInfo, string status, CancellationToken ct)
    {
        var op = await _db.Operations
            .Include(x => x.PlannedOperation)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId && x.Status != OperationStatus.Completed, ct);
        if (op == null) throw new InvalidOperationException("Operation not found");

        if (!Enum.TryParse<OperationStatus>(status, true, out var newStatus))
        {
            throw new InvalidOperationException("Invalid status value");
        }

        var oldStatus = op.Status;
        op.Status = newStatus;
        op.LastStatusChangedAtUtc = DateTimeOffset.UtcNow;
        op.UpdatedAtUtc = DateTimeOffset.UtcNow;
        if (newStatus is OperationStatus.Completed or OperationStatus.Delivered)
        {
            op.IsClosed = true;
            op.ClosedAtUtc = DateTimeOffset.UtcNow;
            //! burada account modülüne publish event çakalım. ödeme alındı mı alınmadı mı onu düşüncem.

        }

        await _db.SaveChangesAsync(ct);

        if (oldStatus != newStatus)
        {
            var occurredAtUtc = DateTimeOffset.UtcNow;
            switch (newStatus)
            {
                case OperationStatus.Completed:
                    await _reports.IncrementSummaryAsync(
                        tenantId,
                        new TenantReportSummaryDelta(CompletedOperations: 1, OpenOperations: -1),
                        ct);
                    await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OperationCompleted, occurredAtUtc, 1, ct);
                    await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OpenOperation, occurredAtUtc, -1, ct);
                    break;
                case OperationStatus.Delivered:
                    await _reports.IncrementSummaryAsync(
                        tenantId,
                        new TenantReportSummaryDelta(DeliveredOperations: 1, OpenOperations: -1),
                        ct);
                    await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OperationDelivered, occurredAtUtc, 1, ct);
                    await IncrementOperationMetricSetAsync(tenantId, TenantReportMetricType.OpenOperation, occurredAtUtc, -1, ct);
                    break;
            }
        }

        return op;
    }

    private async Task IncrementOperationMetricSetAsync(Guid tenantId, TenantReportMetricType metricType, DateTimeOffset occurredAtUtc, long delta, CancellationToken ct)
    {
        await _reports.IncrementPeriodMetricAsync(tenantId, metricType, TenantReportPeriodType.Daily, occurredAtUtc, delta, ct);
        await _reports.IncrementPeriodMetricAsync(tenantId, metricType, TenantReportPeriodType.Monthly, occurredAtUtc, delta, ct);
        await _reports.IncrementPeriodMetricAsync(tenantId, metricType, TenantReportPeriodType.Yearly, occurredAtUtc, delta, ct);
    }


}
