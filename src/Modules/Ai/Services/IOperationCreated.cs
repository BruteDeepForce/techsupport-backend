using System;
using System.Threading;
using System.Threading.Tasks;

namespace TechSupport.Ai.Services
{
    public interface IOperationCreated
    {
        Task HandleOperationCreatedAsync(Guid correlationId, Guid operationId, Guid tenantId, Guid? branchId, string title, string description, string? technicianInfo, string?  customerInfo, string status, DateTimeOffset createdAtUtc, DateTimeOffset? endedAtUtc, DateTimeOffset? assignedAtUtc, CancellationToken cancellationToken);
    }
}
