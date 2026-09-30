namespace TechSupport.Accounting.Contracts.AI;

/// <summary>
/// AI modülünün muhasebe verisini okumasını sağlayan sözleşme.
/// </summary>
public interface IAccountingQueryToAI
{
    /// <summary>
    /// Finansal hesapları (cari hesap, kasa, banka vb.) listeler.
    /// </summary>
    Task<IReadOnlyCollection<AccountInfoResponse>> QueryAccountsAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default);

    /// <summary>
    /// Muhasebe özetini döner: alacak/borç, fatura toplamı, tahsilat, vadesi geçen fatura sayısı.
    /// </summary>
    Task<AccountingSummaryResponse> GetAccountingSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default);

    /// <summary>
    /// Faturaları listeler. Status verilirse sadece o durumdakiler döner.
    /// </summary>
    Task<IReadOnlyCollection<InvoiceInfoResponse>> QueryInvoicesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        Guid? customerId,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Tahsilat/odemeleri listeler. Status verilirse sadece o durumdakiler döner.
    /// </summary>
    Task<IReadOnlyCollection<PaymentInfoResponse>> QueryPaymentsAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Cari hesap hareketlerini (ekstre) tarih aralığı ve müşteri filtresi ile listeler.
    /// </summary>
    Task<IReadOnlyCollection<CariHesapHareketInfoResponse>> QueryCariHesapHareketleriAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? customerId,
        DateTimeOffset? from,
        DateTimeOffset? to,
        int page,
        int pageSize,
        CancellationToken ct = default);
}