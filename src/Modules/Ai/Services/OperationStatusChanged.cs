using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Operation.Contracts.Events;

namespace Ai.Services
{
    public class OperationStatusChanged : IOperationStatusChanged
    {

        private readonly IEmbeddingService _embeddingService;
        public OperationStatusChanged(IEmbeddingService embeddingService)
        {
            _embeddingService = embeddingService;
        }
        public async Task<bool> HandleOperationStatusChangedAsync(Guid correlationId, Guid operationId, Guid tenantId, Guid? branchId, string customerInfo, string technicianInfo, string status, string title, string description, DateTimeOffset? createdAtUtc, DateTimeOffset? assignedAtUtc, DateTimeOffset? endedAtUtc, CancellationToken cancellationToken)
        {
            var operationStatusChanged = new OperationStatusAIEvent
            {
                CorrelationId = correlationId,
                OperationId = operationId,
                TenantId = tenantId,
                BranchId = branchId ?? Guid.Empty, // Handle null branchId by using Guid.Empty or any default value
                CustomerInfo = customerInfo,
                TechnicianInfo = technicianInfo,
                Status = status,
                Title = title,
                Description = description,
                CreatedAtUtc = createdAtUtc,
                AssignedAtUtc = assignedAtUtc,
                EndedAtUtc = endedAtUtc
            };

            return await _embeddingService.UpdateEmbeddingAsync(operationStatusChanged);
        }
    }
}