namespace TechSupport.Accounting.Contracts.AI;

/// <summary>
/// AI tarafına cari/finans hesabı özet bilgisini taşır.
/// </summary>
public sealed record AccountInfoResponse(
    Guid AccountId,
    string AccountNumber,
    string Name,
    string? Description,
    string Type,
    string Status,
    decimal Balance,
    decimal TotalBorc,
    decimal TotalAlacak,
    decimal CreditLimit);

/// <summary>
/// AI tarafına fatura bilgisini taşır.
/// </summary>
public sealed record InvoiceInfoResponse(
    Guid InvoiceId,
    string InvoiceNumber,
    Guid CustomerId,
    string Status,
    string Type,
    decimal TotalAmount,
    decimal PaidAmount,
    decimal RemainingAmount,
    DateTimeOffset IssueDate,
    DateTimeOffset DueDate);

/// <summary>
/// AI tarafına tahsilat/ödeme bilgisini taşır.
/// </summary>
public sealed record PaymentInfoResponse(
    Guid PaymentId,
    string PaymentNumber,
    Guid CustomerId,
    Guid? InvoiceId,
    string Method,
    string Status,
    decimal Amount,
    DateTimeOffset PaymentDate);

/// <summary>
/// AI tarafına cari hesap hareketini (ekstra satırı) taşır.
/// </summary>
public sealed record CariHesapHareketInfoResponse(
    Guid HareketId,
    Guid CustomerId,
    Guid? InvoiceId,
    Guid? PaymentId,
    string HareketTipi,
    decimal Borc,
    decimal Alacak,
    decimal Bakiye,
    string? Aciklama,
    DateTimeOffset IslemTarihi);

/// <summary>
/// AI tarafına tenant/branch seviyesinde muhasebe özetini taşır.
/// </summary>
public sealed record AccountingSummaryResponse(
    decimal TotalReceivable,
    decimal TotalPayable,
    decimal TotalInvoiced,
    decimal TotalPaid,
    decimal TotalUnpaid,
    int InvoiceCount,
    int OverdueInvoiceCount);