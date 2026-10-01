using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.SemanticKernel;
using TechSupport.Ai.Services.SemanticKernel.S3;

namespace Ai.Services.SemanticKernel.Tools
{
    public class PdfGeneratorTool
    {
        private const string DocumentName = "Yapay Zekâ Analiz Raporu";

        private readonly S3Service _s3Service;
        private readonly AiKernelRequestContext _aiKernelRequestContext;

        public PdfGeneratorTool(S3Service s3Service, AiKernelRequestContext aiKernelRequestContext)
        {
            _s3Service = s3Service;
            _aiKernelRequestContext = aiKernelRequestContext;
        }

        [KernelFunction("Generate-Pdf")]
        [Description("Generate a corporate-styled PDF report from the provided content. Also uploads the generated PDF to S3 and returns the file link path.")]
        public async Task<string> GeneratePdf(IReadOnlyCollection<PdfReport> report)
        {
            var sections = (report ?? Array.Empty<PdfReport>())
                .Where(x => x is not null)
                .OrderBy(x => x.Time)
                .ToList();

            var generatedAt = DateTime.UtcNow;
            var tenantId = _aiKernelRequestContext?.TenantId;
            var userId = _aiKernelRequestContext?.UserId;

            var bytes = PdfReportLayout.Generate(sections, generatedAt, tenantId, userId);

            await using var stream = new MemoryStream(bytes);

            var fileName =
                $"Report_{userId}_{tenantId}_{generatedAt:yyyyMMddHHmmss}.pdf";

            var filePath = await _s3Service.UploadPdfFileAsync(
                new FormFile(stream, 0, stream.Length, "file", $"{DocumentName}.pdf"),
                fileName,
                CancellationToken.None);

            return $"PDF Create Success FilePath: {filePath}";
        }
    }

    public sealed record PdfReport(
        string Title,
        string Content,
        DateTime Time);
}
