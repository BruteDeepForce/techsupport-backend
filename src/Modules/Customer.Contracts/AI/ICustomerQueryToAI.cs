namespace TechSupport.Customer.Contracts.AI;

/// <summary>
/// AI modülünün müşteri verisini okumasını sağlayan sözleşme.
/// </summary>
public interface ICustomerQueryToAI
{
    /// <summary>
    /// Müşterileri (cihaz sayısıyla birlikte) listeler. Arama metni ad, e-posta
    /// veya telefon üzerinde uyumsuz (ILIKE) arama yapar.
    /// </summary>
    Task<IReadOnlyCollection<CustomerInfoResponse>> QueryCustomersAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Müşteriye bağlı cihazları listeler. CustomerId verilirse sadece o
    /// müşterinin cihazları döner.
    /// </summary>
    Task<IReadOnlyCollection<CustomerDeviceInfoResponse>> QueryCustomerDevicesAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? customerId,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Müşteri özetini döner: müşteri sayısı, cihaz sayısı, arızalı cihaz ve
    /// garantisi bitmiş cihaz sayıları.
    /// </summary>
    Task<CustomerSummaryResponse> GetCustomerSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default);
}