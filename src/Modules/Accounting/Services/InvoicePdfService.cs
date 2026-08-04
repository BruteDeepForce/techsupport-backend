using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public sealed class InvoicePdfService : IInvoicePdfService
{
    public byte[] Generate(Invoice invoice)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var rows = (invoice.LineItems ?? []).OrderBy(x => x.LineNumber).ToList();
        var currency = ExtractCurrency(invoice.Notes);
        var remaining = Math.Max(0m, invoice.TotalAmount - invoice.PaidAmount);
        var invoiceDate = invoice.IssueDate.ToString("dd/MM/yyyy");
        var customerName = $"Customer {invoice.CustomerId.ToString()[..8].ToUpperInvariant()}";
        const string accentBlue = "#1339A5";
        const string accentCyan = "#35B7E8";
        const string textDark = "#121826";

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(28);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(textDark));

                page.Background().Column(bg =>
                {
                    bg.Item().AlignRight().Width(235).Height(72).Column(col =>
                    {
                        col.Item().Height(14).Background(accentBlue);
                        col.Item().Height(14).Background("#0F2D8D");
                        col.Item().Height(14).Background("#174CBF");
                        col.Item().Height(14).Background("#2D84D6");
                        col.Item().Height(14).Background(accentCyan);
                    });

                    bg.Item().ExtendVertical();

                    bg.Item().AlignLeft().Width(230).Height(58).Column(col =>
                    {
                        col.Item().Height(12).Background(accentCyan);
                        col.Item().Height(12).Background("#2D84D6");
                        col.Item().Height(12).Background("#174CBF");
                        col.Item().Height(12).Background("#0F2D8D");
                    });
                });

                page.Header().Column(header =>
                {
                    header.Item().PaddingTop(8).Row(row =>
                    {
                        row.ConstantItem(52).Height(52).Border(3).BorderColor(accentBlue).AlignMiddle().AlignCenter().Text("L")
                            .FontColor(accentBlue).FontSize(28).SemiBold();
                        row.RelativeItem();
                        row.ConstantItem(230).AlignRight().Column(col =>
                        {
                            col.Item().AlignRight().Text($"FATURA NO: {invoice.InvoiceNumber}").FontSize(10).SemiBold();
                            col.Item().AlignRight().Text($"TARİH: {invoiceDate}").FontSize(10).SemiBold();
                        });
                    });
                });

                page.Content().Column(col =>
                {
                    col.Spacing(10);
                    col.Item().PaddingTop(8).Text("PROFORMA FATURA").FontSize(46f / 2.2f).SemiBold().FontColor(accentBlue);
                    col.Item().Text(string.Empty);
                    col.Item().Text("Sorumlu:").FontSize(12).SemiBold().FontColor(accentBlue);
                    col.Item().Text($"Bireysel/Kurumsal İsim: {customerName}");
                    col.Item().Text("Adres: -");
                    col.Item().Text("Telefon No.: -");

                    col.Item().PaddingTop(14).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.ConstantColumn(48);
                            c.RelativeColumn(3.5f);
                            c.RelativeColumn(1.1f);
                            c.RelativeColumn(1.3f);
                            c.RelativeColumn(1.3f);
                        });

                        table.Header(header =>
                        {
                            header.Cell().Element(CellHeader).Text("No");
                            header.Cell().Element(CellHeader).Text("Açıklama");
                            header.Cell().Element(CellHeader).AlignCenter().Text("Miktar");
                            header.Cell().Element(CellHeader).AlignCenter().Text("Fiyat");
                            header.Cell().Element(CellHeader).AlignCenter().Text("Toplam").SemiBold();
                        });

                        if (rows.Count == 0)
                        {
                            for (var i = 1; i <= 5; i++)
                            {
                                table.Cell().Element(CellBody).Text(i.ToString("00"));
                                table.Cell().Element(CellBody).Text("-");
                                table.Cell().Element(CellBody).AlignCenter().Text("0");
                                table.Cell().Element(CellBody).AlignCenter().Text($"0 {currency}");
                                table.Cell().Element(CellBody).AlignCenter().Text($"0 {currency}");
                            }
                        }
                        else
                        {
                            foreach (var row in rows)
                            {
                                table.Cell().Element(CellBody).Text(row.LineNumber.ToString("00"));
                                table.Cell().Element(CellBody).Text(row.Description);
                                table.Cell().Element(CellBody).AlignCenter().Text(row.Quantity.ToString("0.##"));
                                table.Cell().Element(CellBody).AlignCenter().Text($"{row.UnitPrice:N2} {currency}");
                                table.Cell().Element(CellBody).AlignCenter().Text($"{row.LineTotal:N2} {currency}");
                            }
                        }
                    });

                    col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Medium);

                    col.Item().AlignRight().Width(240).Column(summary =>
                    {
                        summary.Item().Row(r =>
                        {
                            r.RelativeItem().Text("Ara Toplam").SemiBold();
                            r.ConstantItem(96).AlignRight().Text($"{invoice.Subtotal:N2} {currency}").SemiBold();
                        });
                        summary.Item().PaddingTop(2).Row(r =>
                        {
                            r.RelativeItem().Text("Vergi").SemiBold();
                            r.ConstantItem(96).AlignRight().Text($"{invoice.TaxAmount:N2} {currency}").SemiBold();
                        });
                        summary.Item().PaddingTop(2).Row(r =>
                        {
                            r.RelativeItem().Text("Toplam").SemiBold().FontSize(12);
                            r.ConstantItem(96).AlignRight().Text($"{invoice.TotalAmount:N2} {currency}").SemiBold().FontSize(12);
                        });
                    });

                    col.Item().PaddingTop(18).Row(info =>
                    {

                        info.ConstantItem(20);

                        info.RelativeItem().Column(right =>
                        {
                            right.Item().AlignCenter().Text("Ödeme Koşulları").SemiBold().FontColor(accentBlue).FontSize(12);
                            right.Item().PaddingTop(6).Text(
                                "Bu belge teklif faturasıdır. \n Is emri ve teklif kalemleri baz alınarak olusturulmustur. "
                                + $"\n Kalan tutar: {remaining:N2} {currency}. \n Vade tarihi: {invoice.DueDate:dd/MM/yyyy}.")
                                .AlignCenter().FontSize(8.7f);
                        });
                    });
                });

                page.Footer().AlignRight().Text(
                    $"Generated by Lineer Destek | {DateTimeOffset.UtcNow:dd/MM/yyyy HH:mm}",
                    TextStyle.Default.FontSize(8).FontColor(Colors.Grey.Darken1));
            });
        }).GeneratePdf();
    }

    private static string ExtractCurrency(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes))
            return "TRY";

        const string key = "Currency:";
        var idx = notes.IndexOf(key, StringComparison.OrdinalIgnoreCase);
        if (idx < 0)
            return "TRY";

        var value = notes[(idx + key.Length)..].Trim();
        if (string.IsNullOrWhiteSpace(value))
            return "TRY";

        var separatorIndex = value.IndexOfAny([' ', '\n', '\r', ',', ';']);
        if (separatorIndex > 0)
            value = value[..separatorIndex];

        return value.ToUpperInvariant();
    }

    private static IContainer CellHeader(IContainer container) =>
        container
            .Background("#1437A5")
            .PaddingVertical(8)
            .PaddingHorizontal(8)
            .BorderBottom(1)
            .BorderColor("#0D2B87")
            .DefaultTextStyle(x => x.FontColor(Colors.White).FontSize(10));

    private static IContainer CellBody(IContainer container) =>
        container
            .PaddingVertical(8)
            .PaddingHorizontal(8)
            .BorderBottom(1)
            .BorderColor(Colors.Grey.Lighten2);
}
