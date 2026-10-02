using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using IContainer = QuestPDF.Infrastructure.IContainer;

namespace Ai.Services.SemanticKernel.Tools
{
    /// Kurumsal görünümlü analiz raporunun PDF düzenini üretir.
    ///
    /// Araç katmanından ayrı tutulur: burada yalnızca yerleşim vardır, S3
    /// yüklemesi gibi altyapı işleri yoktur.
    public static class PdfReportLayout
    {
        // Kurumsal görünüm dili; muhasebe ve insan kaynakları PDF'leriyle aynı.
        private const string AccentBlue = "#1339A5";
        private const string AccentBlueDark = "#0F2D8D";
        private const string AccentCyan = "#35B7E8";
        private const string TextDark = "#121826";
        private const string TextMuted = "#5A6473";
        private const string SurfaceSoft = "#F4F7FC";
        private const string BorderLight = "#D8E0EE";
        private const string BrandName = "Lineer";
        private const string DocumentName = "Yapay Zekâ Analiz Raporu";

        /// Raporu oluşturur ve PDF baytlarını döndürür.
        ///
        /// Boş bölüm listesi de geçerlidir; bu durumda yalnızca kapak sayfası
        /// ve "veri bulunamadı" notu üretilir.
        public static byte[] Generate(
            IReadOnlyList<PdfReport> sections,
            DateTime generatedAt,
            Guid? tenantId,
            Guid? userId)
        {
            return Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(28);
                    page.DefaultTextStyle(x => x
                        .FontSize(10)
                        .FontColor(TextDark)
                        .LineHeight(1.3f));

                    DrawBackground(page.Background());

                    // Kapak sayfasında marka bandı yoktur; sonraki sayfalarda vardır.
                    page.Header().Height(34).ShowIf(ctx => ctx.PageNumber > 1)
                        .PaddingBottom(6)
                        .BorderBottom(1).BorderColor(BorderLight)
                        .Row(header =>
                        {
                            header.ConstantItem(22).Height(22)
                                .Border(2).BorderColor(AccentBlue)
                                .AlignMiddle().AlignCenter()
                                .Text("L").FontColor(AccentBlue).FontSize(13).SemiBold();
                            header.RelativeItem().PaddingLeft(8)
                                .Text(DocumentName.ToUpperInvariant())
                                .FontSize(9).LetterSpacing(0.6f).SemiBold().FontColor(TextMuted);
                            header.ConstantItem(150).AlignRight()
                                .Text($"{sections.Count} bölüm").FontSize(9).FontColor(TextMuted);
                        });

                    page.Footer().PaddingTop(6)
                        .BorderTop(1).BorderColor(BorderLight)
                        .Row(footer =>
                        {
                            footer.RelativeItem()
                                .Text($"{BrandName} Destek · AI tarafından otomatik üretilmiştir")
                                .FontSize(8).FontColor(TextMuted);
                            footer.ConstantItem(96).AlignRight().Text(text =>
                            {
                                text.DefaultTextStyle(x => x.FontSize(8).FontColor(TextMuted));
                                text.Span("Sayfa ");
                                text.CurrentPageNumber();
                                text.Span(" / ");
                                text.TotalPages();
                            });
                        });

                    page.Content().Column(content =>
                    {
                        content.Spacing(14);

                        DrawCover(content, sections.Count, generatedAt, tenantId, userId);

                        if (sections.Count == 0)
                        {
                            content.Item().PaddingTop(12)
                                .Element(SectionCard)
                                .Text("Rapor için görüntülenecek veri bulunamadı.")
                                .FontColor(TextMuted).FontSize(10).Italic();
                        }
                        else
                        {
                            content.Item().PaddingTop(18);
                            DrawTableOfContents(content, sections);

                            // Bölümler doğal akışta ilerler; her biri kendi
                            // sayfasına zorlanmaz. Aksi hâlde kapak sayfası
                            // dolduğunda araya boş sayfa giriyor.
                            for (var i = 0; i < sections.Count; i++)
                            {
                                DrawSection(content, i + 1, sections[i]);
                            }
                        }
                    });
                });
            }).GeneratePdf();
        }

        private static void DrawBackground(IContainer background)
        {
            background.Column(bg =>
            {
                bg.Item().AlignRight().Width(235).Height(72).Column(col =>
                {
                    col.Item().Height(14).Background(AccentBlue);
                    col.Item().Height(14).Background(AccentBlueDark);
                    col.Item().Height(14).Background("#174CBF");
                    col.Item().Height(14).Background("#2D84D6");
                    col.Item().Height(14).Background(AccentCyan);
                });

                bg.Item().ExtendVertical();

                bg.Item().AlignLeft().Width(230).Height(58).Column(col =>
                {
                    col.Item().Height(12).Background(AccentCyan);
                    col.Item().Height(12).Background("#2D84D6");
                    col.Item().Height(12).Background("#174CBF");
                    col.Item().Height(12).Background(AccentBlueDark);
                });
            });
        }

        private static void DrawCover(
            ColumnDescriptor content,
            int sectionCount,
            DateTime generatedAt,
            Guid? tenantId,
            Guid? userId)
        {
            content.Item().PaddingTop(64).Row(row =>
            {
                row.ConstantItem(58).Height(58)
                    .Border(3).BorderColor(AccentBlue)
                    .AlignMiddle().AlignCenter()
                    .Text("L").FontColor(AccentBlue).FontSize(32).SemiBold();
                row.RelativeItem().PaddingLeft(14).Column(col =>
                {
                    col.Item().Text(BrandName).FontSize(19).SemiBold().FontColor(TextDark);
                    col.Item().PaddingTop(2).Text("Teknik Servis Yönetim Platformu")
                        .FontSize(9.5f).LetterSpacing(0.4f).FontColor(TextMuted);
                });
            });

            content.Item().PaddingTop(34).Text(DocumentName.ToUpperInvariant())
                .FontSize(24).SemiBold().LetterSpacing(0.8f).FontColor(AccentBlue);
            content.Item().PaddingTop(4).Width(260).LineHorizontal(2).LineColor(AccentCyan);

            content.Item().PaddingTop(18)
                .Text("Bu rapor, işletmeniz operasyon verileri üzerinde yapay zekâ "
                      + "tarafından hazırlanmış analiz ve önerileri içerir. Rapor içeriği "
                      + "karar destek amaçlıdır ve bağlayıcı nitelik taşımaz.")
                .FontSize(10).FontColor(TextMuted).LineHeight(1.4f);

            content.Item().PaddingTop(28).Element(InfoPanel).Column(panel =>
            {
                panel.Item().Text("Rapor BİLGİLERİ")
                    .FontSize(8.5f).SemiBold().LetterSpacing(0.8f).FontColor(AccentBlue);
                panel.Item().PaddingTop(8);

                panel.Item().Row(row =>
                {
                    row.ConstantItem(120).Text("Bölüm sayısı").SemiBold();
                    row.RelativeItem().AlignRight().Text(sectionCount.ToString(CultureInfo.InvariantCulture));
                });
                panel.Item().PaddingTop(4).Row(row =>
                {
                    row.ConstantItem(120).Text("Oluşturulma").SemiBold();
                    row.RelativeItem().AlignRight().Text(generatedAt.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture) + " UTC");
                });
                panel.Item().PaddingTop(4).Row(row =>
                {
                    row.ConstantItem(120).Text("Tenant").SemiBold();
                    row.RelativeItem().AlignRight().Text(Short(tenantId));
                });
                panel.Item().PaddingTop(4).Row(row =>
                {
                    row.ConstantItem(120).Text("Kullanıcı").SemiBold();
                    row.RelativeItem().AlignRight().Text(Short(userId));
                });
            });
        }

        private static void DrawTableOfContents(
            ColumnDescriptor content,
            IReadOnlyList<PdfReport> sections)
        {
            content.Item().Text("İÇİNDEKİLER")
                .FontSize(13).SemiBold().LetterSpacing(0.6f).FontColor(AccentBlue);
            content.Item().PaddingTop(4).Width(180).LineHorizontal(1).LineColor(BorderLight);
            content.Item().PaddingTop(10);

            content.Item().Element(SectionCard).Column(list =>
            {
                list.Spacing(7);
                foreach (var section in sections)
                {
                    list.Item().Row(row =>
                    {
                        row.ConstantItem(26).Text(section.Title.Trim())
                            .FontColor(TextMuted).SemiBold();
                        row.RelativeItem().PaddingLeft(8)
                            .LineHorizontal(1).LineColor(BorderLight);
                        row.ConstantItem(96).AlignRight()
                            .Text(section.Time.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture))
                            .FontColor(TextMuted);
                    });
                }
            });
        }

        private static void DrawSection(
            ColumnDescriptor content,
            int index,
            PdfReport section)
        {
            content.Item().Row(row =>
            {
                row.ConstantItem(28).Height(28).Background(AccentBlue)
                    .AlignMiddle().AlignCenter()
                    .Text(index.ToString("00", CultureInfo.InvariantCulture))
                    .FontColor(Colors.White).FontSize(12).SemiBold();
                row.RelativeItem().PaddingLeft(9)
                    .Text(section.Title)
                    .FontSize(15).SemiBold().FontColor(TextDark);
            });

            content.Item().PaddingTop(6).Row(row =>
            {
                row.RelativeItem();
                row.ConstantItem(200).AlignRight()
                    .Text(section.Time.ToString("dd MMMM yyyy · HH:mm", CultureInfo.InvariantCulture))
                    .FontSize(9).FontColor(TextMuted);
            });

            content.Item().PaddingTop(10).Width(64).Height(3).Background(AccentCyan);
            content.Item().PaddingTop(4).Element(SectionCard)
                .Text(Normalize(section.Content))
                .Justify().FontSize(10).FontColor(TextDark).LineHeight(1.45f);
        }

        // ── Ortak stiller ──────────────────────────────────────────────────────

        private static IContainer SectionCard(IContainer container) =>
            container
                .Background(SurfaceSoft)
                .Border(1).BorderColor(BorderLight)
                .CornerRadius(4)
                .PaddingVertical(11).PaddingHorizontal(13);

        private static IContainer InfoPanel(IContainer container) =>
            container
                .Background(SurfaceSoft)
                .Border(1).BorderColor(BorderLight)
                .CornerRadius(4)
                .PaddingVertical(12).PaddingHorizontal(14);

        private static string Normalize(string? content)
        {
            if (string.IsNullOrWhiteSpace(content))
                return "Bu bölüm için açıklama üretilmedi.";

            // Çok fazla boş satır yerleşimi bozuyor.
            return content.Replace("\r\n", "\n").Replace("\r", "\n").Trim();
        }

        private static string Short(Guid? id)
        {
            if (id is null || id == Guid.Empty)
                return "-";

            return id.Value.ToString("N")[..8].ToUpperInvariant();
        }
    }
}
