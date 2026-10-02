namespace TechSupport.Ai.Services.PolicyDocuments;

public interface IPolicyChunkingService
{
    IReadOnlyList<PolicyChunk> CreateChunks(string extractedText, PolicyChunkingOptions? options = null);
}

public sealed record PolicyChunk(
    int ChunkIndex,
    string SectionTitle,
    int? PageStart,
    int? PageEnd,
    int ApproxTokenCount,
    string Text);

public sealed record PolicyChunkingOptions(
    int TargetTokens = 800,
    int MaxTokens = 1100,
    int OverlapTokens = 140,
    int MinTokens = 180);
