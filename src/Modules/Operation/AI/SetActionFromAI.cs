using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Operation.Contracts.AI;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;
using TechSupport.Operation.Services;
namespace TechSupport.Operation.AI
{
    public class SetActionFromAI : ISetActionFromAI
    {
        private readonly ITicketService _ticketService;

        public SetActionFromAI(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }
        public async Task<TechSupport.Operation.Contracts.AI.ResponseOperation> SetTicketToOperation(Guid tenantId,  Guid ticketId, Guid adminUserId, 
            Guid technicianUserId, string technicianName, OpPriority priority, OpType type, CancellationToken ct)
        {
            var techinicanInfo = new TechnicianInfo(technicianUserId, technicianName);

            OperationPriority operationPriority = priority switch
            {
                OpPriority.Normal => OperationPriority.Normal,
                OpPriority.High => OperationPriority.High,
                OpPriority.Urgent => OperationPriority.Urgent,
                _ => throw new ArgumentOutOfRangeException(nameof(priority), priority, null)
            };
            OperationType operationType = type switch
            {
                OpType.Repair => OperationType.Repair,
                OpType.Maintenance => OperationType.Maintenance,
                OpType.Guarantee => OperationType.Guarantee,
                _ => throw new ArgumentOutOfRangeException(nameof(type), type, null)
            };

            var operation = await _ticketService.ConvertAsync(tenantId, ticketId, adminUserId, techinicanInfo, operationType, "AI Assignment to Technician", operationPriority, ct);

            if (operation is null)
            {
                throw new InvalidOperationException("Ticket operation'a donusturulemedi veya daha once donusturulmus olabilir.");
            }

            var occurredAt = operation.AssignedAtUtc ?? operation.CreatedAtUtc;

            return new TechSupport.Operation.Contracts.AI.ResponseOperation(
                operation.Id,
                operation.TenantId,
                operation.BranchId,
                operation.CustomerId,
                operation.DeviceId,
                operation.FieldTechnicianUserId,
                operation.Title,
                operation.Description,
                operation.Status.ToString(),
                operation.InternalNote ?? string.Empty,
                operation.CustomerFullName,
                operation.TechnicianFullName,
                operation.Priority.ToString(),
                occurredAt,
                operation.Type.ToString(),
                operation.MaintenanceTemplateId,
                operation.Future.ToString(),
                operation.PlannedOperation?.ScheduledAtUtc

            );

        }
    }
}