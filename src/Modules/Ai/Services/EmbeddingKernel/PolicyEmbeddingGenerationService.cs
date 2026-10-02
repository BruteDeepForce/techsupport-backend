using Microsoft.EntityFrameworkCore;
using OpenAI.Embeddings;
using TechSupport.Ai.Data;

namespace TechSupport.Ai.Services.PolicyDocuments;

public class PolicyEmbeddingGenerationService : IPolicyEmbeddingGenerationService
{
    private readonly AiDbContext _dbContext;
    private readonly EmbeddingClient _embeddingClient;

    private const string EmbeddingModelName = "azure-openai-embedding";

    public PolicyEmbeddingGenerationService(
        AiDbContext dbContext,
        EmbeddingClient embeddingClient)
    {
        _dbContext = dbContext;
        _embeddingClient = embeddingClient;
    }

    public async Task<PolicyEmbeddingGenerationResult> GenerateAsync(
        Guid tenantId,
        Guid documentId,
        CancellationToken cancellationToken)
    {
        var chunks = await _dbContext.PolicyEmbeddingChunks
            .Where(x => x.TenantId == tenantId && x.DocumentId == documentId)
            .OrderBy(x => x.ChunkIndex)
            .ToListAsync(cancellationToken);

        if (chunks.Count == 0)
        {
            return new PolicyEmbeddingGenerationResult(
                EmbeddingModelName,
                RequestedChunkCount: 0,
                EmbeddedChunkCount: 0,
                FailedChunkCount: 0,
                Completed: true);
        }

        var embedded = 0;
        var failed = 0;

        foreach (var chunk in chunks)
        {
            if (string.IsNullOrWhiteSpace(chunk.ChunkText))
            {
                failed++;
                continue;
            }

            try
            {
                var result = await _embeddingClient.GenerateEmbeddingAsync(chunk.ChunkText, cancellationToken: cancellationToken);
                if (result?.Value is null)
                {
                    failed++;
                    continue;
                }

                var vector = result.Value.ToFloats().ToArray();

                if (vector.Length == 0)
                {
                    failed++;
                    continue;
                }

                chunk.Embedding = new Pgvector.Vector(vector);
                chunk.EmbeddingModel = EmbeddingModelName;
                chunk.UpdatedAtUtc = DateTime.UtcNow;
                embedded++;
            }
            catch
            {
                failed++;
            }
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        return new PolicyEmbeddingGenerationResult(
            EmbeddingModelName,
            RequestedChunkCount: chunks.Count,
            EmbeddedChunkCount: embedded,
            FailedChunkCount: failed,
            Completed: failed == 0);
    }
}
