using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Services;

public sealed class TicketService : ITicketService
{
    private readonly OperationDbContext _db;
    private readonly IBus _bus;
    private readonly IOperationService _ops;

    public TicketService(OperationDbContext db, IBus bus, IOperationService ops)
    {
        _db = db;
        _bus = bus;
        _ops = ops;
    }

    public async Task<Ticket> CreateAsync(Guid tenantId, Guid? branchId, Guid createdBy, string? CustomerName, Guid? deviceId, string title, string description, Priority priority, CancellationToken ct)
    {
        var ticket = new Ticket
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            // CustomerId is inferred from the authenticated user (createdBy)
            CustomerId = createdBy,
            CustomerName = CustomerName,
            DeviceId = deviceId,
            Title = title,
            Description = description,
            Priority = priority,
            Status = TicketStatus.Open,
            CreatedByUserId = createdBy,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        _db.Tickets.Add(ticket);
        await _db.SaveChangesAsync(ct);

        //! Admine publish push notification yapılabilir.

        // await _bus.Publish(new TicketCreated(ticket.Id, ticket.TenantId, ticket.BranchId, ticket.CustomerId, ticket.DeviceId, ticket.Title, ticket.Description, ticket.CreatedAtUtc), ct);

        return ticket;
    }

    public Task<Ticket?> GetAsync(Guid tenantId, Guid ticketId, CancellationToken ct)
    {
        return _db.Tickets.AsNoTracking().Include(t => t.Attachments).FirstOrDefaultAsync(t => t.TenantId == tenantId && t.Id == ticketId, ct);
    }

    public async Task<IEnumerable<Ticket>> AdminGetAllAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.Tickets.AsNoTracking().Where(t => t.TenantId == tenantId).OrderByDescending(t => t.CreatedAtUtc).ToListAsync(ct);
    }

    public async Task<IEnumerable<Ticket>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct)
    {
        return await _db.Tickets.AsNoTracking().Where(t => t.TenantId == tenantId && t.CustomerId == customerId).OrderByDescending(t => t.CreatedAtUtc).ToListAsync(ct);
    }

    public async Task<OperationRecord> ConvertAsync(Guid tenantId, Guid ticketId, Guid adminUserId, TechnicianInfo? technicianInfo, OperationType operationType, string? internalNote, OperationPriority priority, CancellationToken ct)
    {
        //! burası admin yetkisinde ticket to operation dönüşümü için. 
        var ticket = await _db.Tickets.FirstOrDefaultAsync(t => t.TenantId == tenantId && t.Id == ticketId, ct);
        if (ticket is null)
        {
            return null!;
        }
        if (ticket.OperationId.HasValue)
        {
            return null;
        }
        // create operation and associate ticketId
        var op = await _ops.CreateAsync(
            tenantId,
            ticket.BranchId,
            adminUserId,
            technicianInfo?.Name ?? string.Empty,
            ticket.CustomerId,
            ticket.DeviceId ?? Guid.Empty,
            technicianInfo?.TechnicianId,
            ticket.Title,
            ticket.Description,
            internalNote,
            ticket.Id,
            priority,
            operationType,
            null,
            null,
            ct);
            
        // update ticket
        ticket.OperationId = op.Id;
        ticket.Status = TicketStatus.CreatedOperation;
        ticket.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);

        //! customer-technician için publish event gidecek - operation created, ticket converted to operation gibi.
        return op;
    }

    public async Task<Ticket?> RejectAsync(Guid tenantId, Guid ticketId, Guid adminUserId, string reason, CancellationToken ct)
    {
        var ticket = await _db.Tickets.FirstOrDefaultAsync(t => t.TenantId == tenantId && t.Id == ticketId, ct);
        if (ticket is null) return null;

        if (ticket.OperationId.HasValue)
        {
            // Cannot reject a ticket that already became an operation
            throw new InvalidOperationException("Cannot reject a ticket that was already converted to an operation.");
        }

        if (ticket.Status == TicketStatus.Rejected)
        {
            // idempotent: already rejected
            return ticket;
        }

        ticket.Status = TicketStatus.Rejected;
        ticket.UpdatedAtUtc = DateTimeOffset.UtcNow;

        // TODO: persist rejection reason (not modeled in entity) or publish an event

        await _db.SaveChangesAsync(ct);

        //! Optionally publish an event for the rejection so other modules can react
        //await _bus.Publish(new TicketRejected(ticket.Id, ticket.TenantId, adminUserId, reason, DateTimeOffset.UtcNow), ct);

        return ticket;
    }
}
