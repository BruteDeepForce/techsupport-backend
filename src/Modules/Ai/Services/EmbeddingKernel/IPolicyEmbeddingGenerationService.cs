namespace TechSupport.Ai.Services.PolicyDocuments;

public interface IPolicyEmbeddingGenerationService
{
    Task<PolicyEmbeddingGenerationResult> GenerateAsync(
        Guid tenantId,
        Guid documentId,
        CancellationToken cancellationToken);
}

public sealed record PolicyEmbeddingGenerationResult(
    string EmbeddingModel,
    int RequestedChunkCount,
    int EmbeddedChunkCount,
    int FailedChunkCount,
    bool Completed);
