namespace TechSupport.Stock.Contracts.AI;

/// <summary>
/// AI modülünün stok verisini okumasını sağlayan sözleşme.
/// </summary>
public interface IStockQueryToAI
{
    /// <summary>
    /// Stok kartlarını (varsa branch ve arama filtresi ile) listeler.
    /// </summary>
    Task<IReadOnlyCollection<StockItemInfoResponse>> QueryStockItemsAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Stok özetini döner: toplam kart, kritik seviye, mevcut/rezerve miktarlar.
    /// </summary>
    Task<StockSummaryResponse> GetStockSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default);

    /// <summary>
    /// Stok rezervasyonlarını listeler. Status verilirse sadece o durumdakiler döner.
    /// </summary>
    Task<IReadOnlyCollection<StockReservationInfoResponse>> QueryStockReservationsAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Stok hareketlerini (giriş/çıkış/tüketim/iade/rezervasyon) tarih aralığı ile listeler.
    /// </summary>
    Task<IReadOnlyCollection<StockTransactionInfoResponse>> QueryStockTransactionsAsync(
        Guid tenantId,
        Guid? branchId,
        DateTimeOffset? from,
        DateTimeOffset? to,
        int page,
        int pageSize,
        CancellationToken ct = default);
}