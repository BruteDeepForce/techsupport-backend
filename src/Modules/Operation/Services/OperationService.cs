using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.Services;

public interface IOperationService
{
    Task<OperationRecord>   CreateAsync(Guid tenantId, Guid? branchId, Guid createdBy, Guid customerId, Guid deviceId, Guid? toTechnician, string title, string description, string? internalNote, Guid? ticketId, OperationPriority priority, CancellationToken ct);
    Task<OperationRecord?> GetAsync(Guid tenantId, Guid operationId, CancellationToken ct);
    Task<IEnumerable<OperationRecord>> AdminGetAllAsync(Guid tenantId, CancellationToken ct);

    Task<IEnumerable<OperationRecord>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct);

    Task<IEnumerable<OperationRecord>> TechnicianGetAllAsync(Guid tenantId, Guid technicianId, CancellationToken ct);

    Task<OperationRecord> UpdateAsync(Guid tenantId, Guid operationId, Guid updatedBy, string title, string description, Guid? toTechnician, string? internalNote, CancellationToken ct);

    Task<OperationRecord> UpdateStatusAsync(Guid tenantId, Guid operationId, Guid updatedBy, string status, CancellationToken ct);
}

public sealed class OperationService : IOperationService
{
    private readonly OperationDbContext _db;
    private readonly IBus _bus;

    public OperationService(OperationDbContext db, IBus bus)
    {
        _db = db;
        _bus = bus;
    }

    public async Task<OperationRecord> CreateAsync(Guid tenantId,
    Guid? branchId, Guid createdBy,
    Guid customerId, Guid deviceId,
    Guid? toTechnician, string title, string description,
    string? internalNote, Guid? ticketId, OperationPriority priority,
    CancellationToken ct)
    {
        var op = new OperationRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            CustomerId = customerId,
            DeviceId = deviceId,
            CreatedByUserId = createdBy,
            FieldTechnicianUserId = toTechnician,
            TicketId = ticketId,
            Title = title,
            Description = description,
            Priority = priority,
            InternalNote = internalNote,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            AssignedAtUtc = toTechnician.HasValue ? DateTimeOffset.UtcNow : null,
            LastStatusChangedAtUtc = DateTimeOffset.UtcNow
        };

        _db.Operations.Add(op);
        await _db.SaveChangesAsync(ct);

        var now = DateTimeOffset.UtcNow;

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

        if (toTechnician.HasValue)
        {
            await _bus.Publish(new OperationAssignedToTechnician(
                op.Id,
                op.TenantId,
                op.BranchId,
                toTechnician.Value,
                now), ct);
        }

        return op;
    }

    public async Task<OperationRecord?> GetAsync(Guid tenantId, Guid operationId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking().FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId, ct);
    }
    public async Task<IEnumerable<OperationRecord>> AdminGetAllAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking().Where(x => x.TenantId == tenantId).OrderByDescending(x => x.CreatedAtUtc).ToListAsync(ct);
    }

    public async Task<IEnumerable<OperationRecord>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking().Where(x => x.TenantId == tenantId && x.CustomerId == customerId).OrderByDescending(x => x.CreatedAtUtc).ToListAsync(ct);
    }

    public async Task<IEnumerable<OperationRecord>> TechnicianGetAllAsync(Guid tenantId, Guid technicianId, CancellationToken ct)
    {
        return await _db.Operations.AsNoTracking().Where(x => x.TenantId == tenantId && x.FieldTechnicianUserId == technicianId).OrderByDescending(x => x.CreatedAtUtc).ToListAsync(ct);
    }

    public async Task<OperationRecord> UpdateAsync(Guid tenantId, Guid operationId, Guid updatedBy, string title, string description, Guid? toTechnician, string? internalNote, CancellationToken ct)
    {
        var op = await _db.Operations.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId, ct);
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

        await _db.SaveChangesAsync(ct);

        return op;
    }
    public async Task<OperationRecord> UpdateStatusAsync(Guid tenantId, Guid operationId, Guid updatedBy, string status, CancellationToken ct)
    {
        var op = await _db.Operations.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == operationId && x.Status != OperationStatus.Completed, ct);
        if (op == null) throw new InvalidOperationException("Operation not found");

        if (!Enum.TryParse<OperationStatus>(status, true, out var newStatus))
        {
            throw new InvalidOperationException("Invalid status value");
        }

        op.Status = newStatus;
        op.LastStatusChangedAtUtc = DateTimeOffset.UtcNow;
        op.UpdatedAtUtc = DateTimeOffset.UtcNow;
        if (newStatus is OperationStatus.Completed or OperationStatus.Delivered)
        {
            op.IsClosed = true;
            op.ClosedAtUtc = DateTimeOffset.UtcNow;
        }

        await _db.SaveChangesAsync(ct);

        return op;
    }

}
