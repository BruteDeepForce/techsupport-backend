using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using TechSupport.Ai.Data;
using TechSupport.Ai.Services.PolicyDocuments;
using TechSupport.Ai.Services.SemanticKernel.S3;

namespace TechSupport.Ai.Api.Controllers;

[ApiController]
[Route("api/ai/documents")]
[Authorize]
public class DocumentController : ControllerBase
{
    private readonly IPolicyDocumentIngestionService _policyDocumentIngestionService;
    private readonly S3Service _s3Service;
    private readonly AiDbContext _aiDbContext;

    public DocumentController(
        IPolicyDocumentIngestionService policyDocumentIngestionService,
        S3Service s3Service,
        AiDbContext aiDbContext)
    {
        _policyDocumentIngestionService = policyDocumentIngestionService;
        _s3Service = s3Service;
        _aiDbContext = aiDbContext;
    }

    [HttpPost("upload")]
    [RequestSizeLimit(20 * 1024 * 1024)]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadAndStartPipeline(
        [FromForm] PolicyDocumentUploadRequest request,
        CancellationToken cancellationToken)
    {
        var role = User.FindFirstValue(ClaimTypes.Role);
        if (role != "admin")
        {
            return Unauthorized("You must be an Admin to access this endpoint.");
        }

        var tenantId = User.FindFirstValue("tenant_id");
        Guid.TryParse(tenantId, out var tenantGuid);
        if (tenantGuid == Guid.Empty)
        {
            return BadRequest("Geçersiz tenant bilgisi.");
        }

        var branchId = User.FindFirstValue("branch_id");
        Guid.TryParse(branchId, out var branchGuid);

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        Guid.TryParse(userId, out var userGuid);
        if (userGuid == Guid.Empty)
        {
            return BadRequest("Geçersiz kullanıcı bilgisi.");
        }

        try
        {
            var result = await _policyDocumentIngestionService.UploadAndExtractAsync(
                tenantGuid,
                branchGuid == Guid.Empty ? null : branchGuid,
                userGuid,
                request.File,
                request.DocumentName,
                cancellationToken);

            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    [HttpGet("list")]
    public async Task<IActionResult> ListDocuments(
        CancellationToken cancellationToken)
    {
        var tenantId = User.FindFirstValue("tenant_id");
        Guid.TryParse(tenantId, out var tenantGuid);
        if (tenantGuid == Guid.Empty)
        {
            return BadRequest("Geçersiz tenant bilgisi.");
        }

        try
        {
            var documents = await _s3Service.GetDocumentsFromS3Async(
                tenantGuid,
                cancellationToken);

            var documentIds = documents
                .Select(d => TryParseDocumentIdFromS3Key(d.Key))
                .Where(id => id.HasValue)
                .Select(id => id!.Value)
                .Distinct()
                .ToList();

            var documentNamesById = await _aiDbContext.PolicyEmbeddingChunks
                .AsNoTracking()
                .Where(x => x.TenantId == tenantGuid && documentIds.Contains(x.DocumentId))
                .GroupBy(x => x.DocumentId)
                .Select(g => new
                {
                    DocumentId = g.Key,
                    DocumentName = g.Select(x => x.DocumentName).FirstOrDefault()
                })
                .ToDictionaryAsync(x => x.DocumentId, x => x.DocumentName, cancellationToken);

            var enriched = documents.Select(d =>
            {
                var id = TryParseDocumentIdFromS3Key(d.Key);
                if (id.HasValue && documentNamesById.TryGetValue(id.Value, out var dbName) && !string.IsNullOrWhiteSpace(dbName))
                {
                    return new S3Service.PolicyDocument(dbName, d.Key, d.Url);
                }

                return d;
            });

            return Ok(enriched);
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }

    private static Guid? TryParseDocumentIdFromS3Key(string key)
    {
        if (string.IsNullOrWhiteSpace(key))
            return null;

        var fileName = Path.GetFileNameWithoutExtension(key);
        var separatorIndex = fileName.IndexOf('_');
        if (separatorIndex <= 0)
            return null;

        var rawDocumentId = fileName[..separatorIndex];
        return Guid.TryParse(rawDocumentId, out var documentId) ? documentId : null;
    }

    public sealed class PolicyDocumentUploadRequest
    {
        [Required]
        public IFormFile File { get; set; } = null!;

        public string? DocumentName { get; set; }
    }
}
