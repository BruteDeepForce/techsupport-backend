using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Threading.Tasks;
using Azure.AI.OpenAI.Chat;
using Pgvector.EntityFrameworkCore;
using TechSupport.Ai.Data;
using Microsoft.EntityFrameworkCore;

namespace Ai.Services
{
    public class EmbeddingQueryService : IEmbeddingQueryService
    {
        private readonly IEmbeddingService _embeddingService;

        private readonly AiDbContext _dbContext;
        
        public EmbeddingQueryService(IEmbeddingService embeddingService, AiDbContext dbContext)
        {
            _embeddingService = embeddingService;
            _dbContext = dbContext;
        }
        public async Task<IEnumerable<EmbeddingResult>> QuerySimilarEmbeddingsAsync(string queryText, Guid tenantId)
        {
            var embedding = await _embeddingService.GenerateEmbeddingForTextAsync(queryText, tenantId);

            var vectorize = new Pgvector.Vector(embedding);

            int top = await _dbContext.Embeddings.CountAsync(e => e.TenantId == tenantId && e.Embedding != null);

            var nearest = await _dbContext.Embeddings
                .Where(e => e.TenantId == tenantId && e.Embedding != null)
                .OrderBy(e => e.Embedding!.CosineDistance(vectorize))
                .Select(e => new EmbeddingResult
                {
                    Id = e.Id,
                    ChunkText = e.ChunkText,
                    Similarity = (double)(1 - e.Embedding!.CosineDistance(vectorize)), // Convert distance to similarity
                    SourceModule = e.SourceModule,
                    Entity = e.Entity,
                    EntityId = e.EntityId
                })
                .Take(top)
                .ToListAsync();
                
            return nearest;
        }
    }
}