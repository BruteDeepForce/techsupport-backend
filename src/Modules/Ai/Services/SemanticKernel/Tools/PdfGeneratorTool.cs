using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading.Tasks;
using Azure;
using Microsoft.SemanticKernel;
using QuestPDF;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Ai.Services.SemanticKernel.Tools
{
    public class PdfGeneratorTool
    {
        [KernelFunction("Generate-Pdf")]
        [Description("Generate a PDF document from the provided content.")]
        public string GeneratePdf(IReadOnlyCollection<PdfReport> report)
        {
            string filePath = Path.Combine(Directory.GetCurrentDirectory(),"Rapor.pdf");

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
            }).GeneratePdf(filePath);

            return $"PDF Create Success FilePath: {filePath}";
        }


    }

    public sealed record PdfReport(
        string Title,
        string Content,
        DateTime Time);
}