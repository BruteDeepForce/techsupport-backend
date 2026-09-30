using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Contracts.AI;
using TechSupport.Operation.Data;
using TechSupport.Operation.Services;

namespace TechSupport.Operation.AI
{
    public class OperationQueryToAI : IOperationQueryToAI
    {
        private readonly OperationDbContext _db;

        public OperationQueryToAI(OperationDbContext db)
        {
            _db = db;
        }
        public async Task<IReadOnlyCollection<ResponseOperation>> CheckAllOperations(Guid tenantId, Guid branchId,  DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize)
        {
            var operations = await _db.Operations
                .Include(o=> o.PlannedOperation)
                .AsNoTracking()
                .Where(o => o.TenantId == tenantId && o.BranchId == branchId && (!From.HasValue || o.CreatedAtUtc >= From.Value.UtcDateTime) && (!To.HasValue || o.CreatedAtUtc <= To.Value.UtcDateTime))
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return operations.Select(o => new ResponseOperation(
                o.Id,
                o.TenantId,
                o.BranchId,
                o.CustomerId,
                o.DeviceId,
                o.FieldTechnicianUserId,
                o.Title,
                o.Description,
                o.Status.ToString(),
                o.InternalNote,
                o.CustomerFullName,
                o.TechnicianFullName,
                o.Priority.ToString(),
                o.CreatedAtUtc,
                o.Type.ToString(),
                o.MaintenanceTemplateId,
                o.Future.ToString(),
                o.PlannedOperation?.ScheduledAtUtc
            )).ToList();
        }

        public async Task<IReadOnlyCollection<ResponseTicket>> CheckAllTickets(Guid tenantId, Guid branchId, DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize)
        {
            var tickets = await _db.Tickets
                .Include(t => t.Attachments)
                .AsNoTracking()
                .Where(t => t.TenantId == tenantId && t.BranchId == branchId && (!From.HasValue || t.CreatedAtUtc >= From.Value.UtcDateTime) && (!To.HasValue || t.CreatedAtUtc <= To.Value.UtcDateTime))
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return tickets.Select(t => new ResponseTicket(
                t.Id,
                t.TenantId,
                t.BranchId,
                t.CustomerId,
                t.DeviceId,
                t.CustomerName,
                t.OperationId,
                t.Title,
                t.Description,
                t.Priority.ToString(),
                t.Status.ToString(),
                t.CreatedByUserId,
                t.CreatedAtUtc,
                t.UpdatedAtUtc,
                t.Attachments.Select(a => new TicketAttachment(
                    a.Id,
                    a.FileName,
                    a.Url,
                    a.CreatedAtUtc
                )).ToList()
            )).ToList();
        }
    }
}