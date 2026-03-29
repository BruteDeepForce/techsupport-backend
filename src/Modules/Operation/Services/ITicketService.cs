using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Services;

public interface ITicketService
{
    Task<Ticket> CreateAsync(Guid tenantId, Guid? branchId, Guid createdBy, Guid? deviceId, string title, string description, Priority priority, CancellationToken ct);
    Task<Ticket?> GetAsync(Guid tenantId, Guid ticketId, CancellationToken ct);
    Task<IEnumerable<Ticket>> AdminGetAllAsync(Guid tenantId, CancellationToken ct);
    Task<IEnumerable<Ticket>> CustomerGetAllAsync(Guid tenantId, Guid customerId, CancellationToken ct);
    Task<OperationRecord> ConvertAsync(Guid tenantId, Guid ticketId, Guid adminUserId, TechnicianInfo? technicianInfo, OperationType operationType,string? internalNote, OperationPriority priority, CancellationToken ct);
    Task<Ticket?> RejectAsync(Guid tenantId, Guid ticketId, Guid adminUserId, string reason, CancellationToken ct);
}
