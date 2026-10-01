using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Operation.Contracts.AI;

namespace TechSupport.Operation.Contracts.OutRequest
{
    public interface IOperationRequest
    {
        Task<IReadOnlyCollection<ResponseOperation>> GetOperationsAsync(Guid tenantId, CancellationToken cancellationToken);

        Task<IReadOnlyCollection<ResponseTicket>> GetTicketsAsync(Guid tenantId, CancellationToken cancellationToken);
    }
}