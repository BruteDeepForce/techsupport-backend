using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading.Tasks;
using Azure;
using Microsoft.AspNetCore.Http;
using Microsoft.SemanticKernel;
using QuestPDF;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TechSupport.Ai.Services.SemanticKernel.S3;

namespace Ai.Services.SemanticKernel.Tools
{
    public class PdfGeneratorTool
    {
        private readonly S3Service _s3Service;
        private readonly AiKernelRequestContext _aiKernelRequestContext;

        public PdfGeneratorTool(S3Service s3Service, AiKernelRequestContext aiKernelRequestContext)
        {
            _s3Service = s3Service;
            _aiKernelRequestContext = aiKernelRequestContext;
        }
        [KernelFunction("Generate-Pdf")]
        [Description("Generate a PDF document from the provided content.")]
        public async Task<string> GeneratePdf(IReadOnlyCollection<PdfReport> report)
        {

            await using (var stream = new MemoryStream())
            {
                QuestPDF.Fluent.Document.Create(container =>
                {
                  container.Page(page =>
                  {
                      page.Size(PageSizes.A4);
                      page.Margin(2, Unit.Centimetre);
                      page.Header().Text("Lineer AI Report");

                      page.Content().Column(column =>
                      {
                          foreach (var item in report)
                          {
                              column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                              column.Item().PaddingVertical(5).BorderBottom(1).BorderColor(Colors.Grey.Lighten2);
                              column.Item().Text(item.Title).FontSize(20).Bold();
                              column.Item().Text(item.Content).FontSize(12);
                              column.Item().Text(item.Time.ToString("yyyy-MM-dd HH:mm:ss")).FontSize(10).Italic();
                          }
                      });

                  });
                }).GeneratePdf(stream);

                stream.Position = 0;

                 var filePath = await _s3Service.UploadPdfFileAsync(new FormFile(stream, 0, stream.Length, 
                 "file", "Rapor.pdf"), $"Report_{_aiKernelRequestContext.UserId}_{_aiKernelRequestContext.TenantId}_{DateTime.UtcNow:yyyyMMddHHmmss}.pdf"
                 , CancellationToken.None);
                 return $"PDF Create Success FilePath: {filePath}";
            }
        }
    }

    public sealed record PdfReport(
        string Title,
        string Content,
        DateTime Time);
}