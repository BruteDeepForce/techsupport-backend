using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using Ai.Services.SemanticKernel.Tools.EmbeddingQuery.DTOs;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using OpenAI.Embeddings;
using Pgvector.EntityFrameworkCore;
using TechSupport.Ai.Data;

namespace Ai.Services.SemanticKernel.Tools.Embedding
{
    public class EmbeddingQueryTool
    {
        private readonly AiDbContext _aiDbContext;
        private readonly AiKernelRequestContext _aiKernelRequestContext;

        private readonly EmbeddingClient _embeddingClient;

        private readonly ILogger<EmbeddingQueryTool> _logger;

        public EmbeddingQueryTool(AiDbContext aiDbContext, AiKernelRequestContext aiKernelRequestContext,
            EmbeddingClient embeddingClient, ILogger<EmbeddingQueryTool> logger)
        {
            _aiDbContext = aiDbContext;
            _aiKernelRequestContext = aiKernelRequestContext;
            _embeddingClient = embeddingClient;
            _logger = logger;
        }
        [KernelFunction("query_embedding")]
        [Description("Queries the embedding database for the most relevant chunks based on the input query. For example company policy documents")] 
        public async Task<IEnumerable<AIEmbeddingResponseDTO>> QueryEmbeddingAsync(string query, int topK)
        {
            var tenantId = _aiKernelRequestContext.TenantId;
            var branchId = _aiKernelRequestContext.BranchId;
            var userId = _aiKernelRequestContext.UserId;

            _logger.LogInformation("Embedding query context tenantId={TenantId}, branchId={BranchId}, userId={UserId}",
                tenantId,
                branchId,
                userId);

            if (string.IsNullOrWhiteSpace(query))
            {
                _logger.LogWarning("QueryEmbeddingAsync called with empty query.");
                return Enumerable.Empty<AIEmbeddingResponseDTO>();
            }

            var safeTopK = Math.Clamp(topK, 1, 20);
            _logger.LogInformation("QueryEmbeddingAsync called with query: {Query} and topK: {TopK}", query, safeTopK);

            var embeddingQuery = await _embeddingClient.GenerateEmbeddingAsync(query.Trim());

            _logger.LogInformation("Generated embedding: {Embedding}", embeddingQuery.Value);

            var toFloat = embeddingQuery.Value.ToFloats().ToArray();
            _logger.LogInformation("Generated embedding for query: {Query}", query);
            var vectorize = new Pgvector.Vector(toFloat);

            var chunks = await _aiDbContext.PolicyEmbeddingChunks
                .AsNoTracking()
                .Where(chunk =>
                    chunk.TenantId == tenantId &&
                    chunk.Embedding != null)
                .ToListAsync();
            _logger.LogInformation("Retrieved {Count} chunks for tenant: {TenantId}", chunks.Count, tenantId);

            var nearest = await _aiDbContext.PolicyEmbeddingChunks
                .AsNoTracking()
                .Where(chunk =>
                    chunk.TenantId == tenantId &&
                    chunk.Embedding != null)
                .OrderBy(chunk => chunk.Embedding!.CosineDistance(vectorize))
                .Select(chunk => new AIEmbeddingResponseDTO
                {
                    DocumentId = chunk.DocumentId,
                    DocumentName = chunk.DocumentName,
                    SectionTitle = chunk.SectionTitle,
                    ChunkIndex = chunk.ChunkIndex,
                    ChunkText = chunk.ChunkText,
                    CreatedAtUtc = chunk.CreatedAtUtc,
                    UpdatedAtUtc = chunk.UpdatedAtUtc
                })
                .Take(safeTopK)
                .ToListAsync();
            _logger.LogInformation("Retrieved {Count} nearest embedding results for query: {Query}", nearest.Count, query);

            return nearest;

        }

    }
}