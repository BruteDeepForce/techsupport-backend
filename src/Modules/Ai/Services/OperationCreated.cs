using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Ai.Services;
using TechSupport.Ai.Data;

namespace TechSupport.Ai.Services
{
    public class OperationCreated : IOperationCreated
    {
        private readonly IEmbeddingService _embeddingService;
        public OperationCreated(IEmbeddingService embeddingService)
        {
            _embeddingService = embeddingService;
        }

        public async Task HandleOperationCreatedAsync(Guid correlationId, Guid operationId, Guid tenantId, 
        Guid? branchId, string title, string description, string? technicianInfo, 
        string? customerInfo, string status, DateTimeOffset createdAtUtc, DateTimeOffset? endedAtUtc, DateTimeOffset? assignedAtUtc, CancellationToken cancellationToken)
        {

                var operationCreatedEvent = new TechSupport.Operation.Contracts.Events.OperationCreatedToAI
                {
                    OperationId = operationId,
                    TenantId = tenantId,
                    BranchId = branchId ?? Guid.Empty,
                    Title = title,
                    Description = description,
                    TechnicianInfo = technicianInfo,
                    CustomerInfo = customerInfo,
                    Status = string.IsNullOrEmpty(status) ? "Open" : status,
                    CreatedAtUtc = createdAtUtc,
                    EndedAtUtc = endedAtUtc,
                    AssignedAtUtc = assignedAtUtc
                };
    
                await _embeddingService.GenerateEmbeddingAsync(operationCreatedEvent);
            
                        
            await Task.CompletedTask;
        }
    }
}