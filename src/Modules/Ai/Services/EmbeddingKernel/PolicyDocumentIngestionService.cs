using System.Text;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Http;
using TechSupport.Ai.Data;
using TechSupport.Ai.Domain.Entities;
using TechSupport.Ai.Services.SemanticKernel.S3;
using UglyToad.PdfPig;

namespace TechSupport.Ai.Services.PolicyDocuments;

public class PolicyDocumentIngestionService : IPolicyDocumentIngestionService
{
    private const long MaxFileSizeBytes = 20 * 1024 * 1024;
    private const int PreviewMaxLength = 2000;
    private const int ChunkPreviewCount = 5;
    private const int ChunkPreviewTextMaxLength = 220;
    private const string EmbeddingModelPending = "pending:chunked-not-embedded";

    private readonly S3Service _s3Service;
    private readonly IPolicyChunkingService _policyChunkingService;
    private readonly IPolicyEmbeddingGenerationService _policyEmbeddingGenerationService;
    private readonly AiDbContext _dbContext;

    public PolicyDocumentIngestionService(
        S3Service s3Service,
        IPolicyChunkingService policyChunkingService,
        IPolicyEmbeddingGenerationService policyEmbeddingGenerationService,
        AiDbContext dbContext)
    {
        _s3Service = s3Service;
        _policyChunkingService = policyChunkingService;
        _policyEmbeddingGenerationService = policyEmbeddingGenerationService;
        _dbContext = dbContext;
    }

    public async Task<PolicyDocumentUploadResult> UploadAndExtractAsync(
        Guid tenantId,
        Guid? branchId,
        Guid userId,
        IFormFile file,
        string? documentName,
        CancellationToken cancellationToken)
    {
        if (file is null || file.Length == 0)
            throw new InvalidOperationException("PDF dosyasi bos olamaz.");

        if (file.Length > MaxFileSizeBytes)
            throw new InvalidOperationException("PDF dosyasi 20 MB sinirini asamaz.");

        var extension = Path.GetExtension(file.FileName);
        if (!string.Equals(extension, ".pdf", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Sadece PDF yuklenebilir.");

        //! ramde geçici olarak tutuyoruz
        await using var uploadStream = new MemoryStream();
        await file.CopyToAsync(uploadStream, cancellationToken);
        uploadStream.Position = 0;

        var textBuilder = new StringBuilder();
        var pageCount = 0;

        using (var pdf = PdfDocument.Open(uploadStream))
        {
            pageCount = pdf.NumberOfPages;
            foreach (var page in pdf.GetPages())
            {
                if (textBuilder.Length > 0)
                    textBuilder.AppendLine();

                textBuilder.AppendLine($"[Page {page.Number}]");
                textBuilder.AppendLine(page.Text);
            }
        }
        //! PDF metnini txt cikarttik
        var extractedText = NormalizeText(textBuilder.ToString());

        //! PDF metnini parcalara ayiriyoruz indeksler önemli token boyutu da dikkate aliniyor
        var chunks = _policyChunkingService.CreateChunks(extractedText);

        // Rewind for S3 upload after extraction consumed the stream.
        uploadStream.Position = 0;

        var safeDocumentName = string.IsNullOrWhiteSpace(documentName)
            ? Path.GetFileNameWithoutExtension(file.FileName)
            : documentName.Trim();

        var documentId = Guid.NewGuid();
        var key =
            $"policy/{tenantId}/{documentId}_{DateTime.UtcNow:yyyyMMddHHmmss}.pdf";

        var uploadFile = new FormFile(uploadStream, 0, uploadStream.Length, "file", file.FileName)
        {
            Headers = new HeaderDictionary(),
            ContentType = "application/pdf"
        };
        //! PDF dosyasini S3'e yukleme işlemini baslatiyoruz
        var storageUrl = await _s3Service.UploadPdfFileAsync(
            uploadFile,
            key,
            cancellationToken);

        var preview = extractedText.Length <= PreviewMaxLength
            ? extractedText
            : extractedText[..PreviewMaxLength];
        //! PDF metninin onizlemelerini hazirliyoruz
        var chunkPreviews = chunks
            .Take(ChunkPreviewCount)
            .Select(c => new PolicyChunkPreview(
                ChunkIndex: c.ChunkIndex,
                SectionTitle: c.SectionTitle,
                PageStart: c.PageStart,
                PageEnd: c.PageEnd,
                ApproxTokenCount: c.ApproxTokenCount,
                PreviewText: c.Text.Length <= ChunkPreviewTextMaxLength
                    ? c.Text
                    : c.Text[..ChunkPreviewTextMaxLength]))
            .ToList();

        var now = DateTime.UtcNow;

        //! öncelikle chunk olarak embeddingsiz db ye insert
        var chunkEntities = chunks.Select(c => new PolicyEmbeddingChunk
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            DocumentId = documentId,
            DocumentName = safeDocumentName,
            SectionTitle = c.SectionTitle,
            ChunkIndex = c.ChunkIndex,
            ChunkText = c.Text,
            Embedding = null,
            EmbeddingModel = EmbeddingModelPending,
            CreatedAtUtc = now,
            UpdatedAtUtc = null
        }).ToList();

        await _dbContext.PolicyEmbeddingChunks.AddRangeAsync(chunkEntities, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        //! chunklar db ye eklendikten sonra embedding olusturma islemini baslatiyoruz
        var embeddingResult = await _policyEmbeddingGenerationService.GenerateAsync(
            tenantId,
            documentId,
            cancellationToken);

        return new PolicyDocumentUploadResult(
            DocumentId: documentId,
            DocumentName: safeDocumentName,
            StorageUrl: storageUrl,
            PageCount: pageCount,
            ChunkCount: chunks.Count,
            EmbeddedChunkCount: embeddingResult.EmbeddedChunkCount,
            FailedChunkCount: embeddingResult.FailedChunkCount,
            EmbeddingCompleted: embeddingResult.Completed,
            EmbeddingModel: embeddingResult.EmbeddingModel,
            ExtractedCharacterCount: extractedText.Length,
            TextPreview: preview,
            ChunkPreviews: chunkPreviews,
            UploadedAtUtc: DateTime.UtcNow);
    }

    private static string NormalizeText(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return string.Empty;

        var normalized = raw.Replace("\r", "\n");
        normalized = Regex.Replace(normalized, "\\n{3,}", "\n\n");
        normalized = Regex.Replace(normalized, "[ \t]{2,}", " ");
        return normalized.Trim();
    }

}
