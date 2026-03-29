using System;
using System.ClientModel;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using OpenAI;
using OpenAI.Embeddings;
using TechSupport.Ai.Data;
using TechSupport.Operation.Contracts.Events;

namespace Ai.Services
{
    public class EmbeddingService : IEmbeddingService
    {
        private readonly ILogger<EmbeddingService> _logger;
        private readonly AiDbContext _dbContext;
        private readonly EmbeddingClient _embeddingClient;

        public EmbeddingService(ILogger<EmbeddingService> logger, AiDbContext dbContext, EmbeddingClient embeddingClient)
        {
            _logger = logger;
            _dbContext = dbContext;
            _embeddingClient = embeddingClient;
        }
        public async Task<bool> GenerateEmbeddingAsync(OperationCreatedToAI operationCreated)
        {
            string inputText = $"İş Emri Başlık: {operationCreated.Title}\nDescription: {operationCreated.Description}\nStatus: {operationCreated.Status}\nTechnician Info: {operationCreated.TechnicianInfo}\nCustomer Info: {operationCreated.CustomerInfo}\nCreated At: {operationCreated.CreatedAtUtc}\nEnded At: {operationCreated.EndedAtUtc}\nAssigned At: {operationCreated.AssignedAtUtc}\n";

            _logger.LogInformation("Generating embedding for input text of length {Length}", inputText.Length);

            //! circuit breaker için OpenAIClientException yakalayarak retry mekanizması eklenebilir. 
            //!Ancak şu an için basit bir implementasyon yapıldı.
            ClientResult<OpenAIEmbedding> embeddingResult = await _embeddingClient.GenerateEmbeddingAsync(inputText);
            _logger.LogInformation("Embedding generation completed");

            if (embeddingResult?.Value != null)
            {
                var record = new TechSupport.Ai.Domain.Entities.EmbeddingRecord
                {
                    Id = Guid.NewGuid(),
                    TenantId = operationCreated.TenantId,
                    BranchId = operationCreated.BranchId,
                    SourceModule = "operation",
                    Entity = "operation",
                    EntityId = operationCreated.OperationId,
                    ChunkText = inputText,
                    Embedding = new Pgvector.Vector(embeddingResult.Value.ToFloats().ToArray()),
                };

                await _dbContext.Embeddings.AddAsync(record);
                await _dbContext.SaveChangesAsync();

                return true;

            }
            else
            {
                _logger.LogError("Failed to generate embedding or received null value for OperationId: {OperationId}", operationCreated.OperationId);
                return false;
            }

        }
        public async Task<float[]> GenerateEmbeddingForTextAsync(string text, Guid tenantId)
        {
            _logger.LogInformation("Generating embedding for input text of length {Length}", text.Length);
            ClientResult<OpenAIEmbedding> embeddingResult = await _embeddingClient.GenerateEmbeddingAsync(text);
            _logger.LogInformation("Embedding generation completed");

            if (embeddingResult?.Value != null)
            {
                var result = embeddingResult.Value.ToFloats().ToArray();
                _logger.LogInformation("Generated embedding of length {Length} for TenantId: {TenantId}", result.Length, tenantId);
                return result;

            }
            else
            {
                _logger.LogError("Failed to generate embedding or received null value for custom text input for TenantId: {TenantId}", tenantId);
                return Array.Empty<float>();
            }
        }
        public async Task<bool> UpdateEmbeddingAsync(OperationStatusAIEvent operationStatusChanged)
        {

                var existingRecord = await _dbContext.Embeddings.FirstOrDefaultAsync(e => e.Entity == "operation" && e.EntityId == operationStatusChanged.OperationId);
                if (existingRecord != null)
                {
                    string updatedText = $"İş Emri Başlık: {operationStatusChanged.Title}\nDescription: {operationStatusChanged.Description}\nStatus: {operationStatusChanged.Status}\nTechnician Info: {operationStatusChanged.TechnicianInfo}\nCustomer Info: {operationStatusChanged.CustomerInfo}\nCreated At: {operationStatusChanged.CreatedAtUtc}\nEnded At: {operationStatusChanged.EndedAtUtc}\nAssigned At: {operationStatusChanged.AssignedAtUtc}\n";
    
                    ClientResult<OpenAIEmbedding> embeddingResult = await _embeddingClient.GenerateEmbeddingAsync(updatedText);
    
                    if (embeddingResult?.Value != null)
                    {
                        existingRecord.ChunkText = updatedText;
                        existingRecord.Embedding = new Pgvector.Vector(embeddingResult.Value.ToFloats().ToArray());
                        existingRecord.CreatedAtUtc = DateTime.UtcNow;

    
                        _dbContext.Embeddings.Update(existingRecord);
                        await _dbContext.SaveChangesAsync();
    
                        return true;
                    }
                    else
                    {
                        _logger.LogError("Failed to generate embedding for updated operation status for OperationId: {OperationId}", operationStatusChanged.OperationId);
                        return false;
                    }
                }
                else
                {
                    _logger.LogWarning("No existing embedding record found for OperationId: {OperationId} to update", operationStatusChanged.OperationId);
                    return false;
                }

        }
    }
}
