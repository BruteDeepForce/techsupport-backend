using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Operation.Contracts.Events;

namespace Ai.Services
{
    public interface IEmbeddingService
    {
        Task<bool> GenerateEmbeddingAsync(OperationCreatedToAI operationCreated);  

        Task<float[]> GenerateEmbeddingForTextAsync(string text, Guid tenantId);

        Task<bool> UpdateEmbeddingAsync(OperationStatusAIEvent operationStatusChanged);
    }
}