using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Contracts.AI
{
    public interface IOperationQueryToAI
    {
        Task<IReadOnlyCollection<ResponseOperation>> CheckAllOperations(Guid tenantId, Guid branchId, DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize);

        Task<IReadOnlyCollection<ResponseTicket>> CheckAllTickets(Guid tenantId, Guid branchId, DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize);
        
    }
}