using Microsoft.AspNetCore.Http;

namespace TechSupport.Ai.Services.PolicyDocuments;

public interface IPolicyDocumentIngestionService
{
    Task<PolicyDocumentUploadResult> UploadAndExtractAsync(
        Guid tenantId,
        Guid? branchId,
        Guid userId,
        IFormFile file,
        string? documentName,
        CancellationToken cancellationToken);
}

public sealed record PolicyDocumentUploadResult(
    Guid DocumentId,
    string DocumentName,
    string StorageUrl,
    int PageCount,
    int ChunkCount,
    int EmbeddedChunkCount,
    int FailedChunkCount,
    bool EmbeddingCompleted,
    string EmbeddingModel,
    int ExtractedCharacterCount,
    string TextPreview,
    IReadOnlyList<PolicyChunkPreview> ChunkPreviews,
    DateTime UploadedAtUtc);

public sealed record PolicyChunkPreview(
    int ChunkIndex,
    string SectionTitle,
    int? PageStart,
    int? PageEnd,
    int ApproxTokenCount,
    string PreviewText);
