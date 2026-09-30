using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Contracts.AI
{
    public interface ISetActionFromAI
    {
        Task<ResponseOperation> SetTicketToOperation(Guid tenantId,  Guid ticketId, Guid adminUserId, 
        Guid technicianUserId, string technicianName, OpPriority priority, OpType type, CancellationToken cancellationToken);
    }
}