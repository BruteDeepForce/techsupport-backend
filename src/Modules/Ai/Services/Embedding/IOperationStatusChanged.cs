using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Ai.Services
{
    public interface IOperationStatusChanged
    {
        Task<bool> HandleOperationStatusChangedAsync(Guid correlationId, Guid operationId, Guid tenantId, Guid? branchId, string customerInfo, string technicianInfo, string status, string Title, string Description, DateTimeOffset? createdAtUtc, DateTimeOffset? assignedAtUtc, DateTimeOffset? endedAtUtc, CancellationToken cancellationToken);
        
    }
}