namespace TechSupport.Hr.Contracts.AI;

/// <summary>
/// AI modülünün insan kaynakları verisini okumasını sağlayan sözleşme.
/// </summary>
public interface IHrQueryToAI
{
    /// <summary>
    /// Çalışanları departman/görev bilgisiyle listeler. Arama metni sicil no,
    /// ad, e-posta veya telefon üzerinde uyumsuz (ILIKE) arama yapar.
    /// </summary>
    Task<IReadOnlyCollection<EmployeeInfoResponse>> QueryEmployeesAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// İzin kayıtlarını listeler. Status verilirse sadece o durumdakiler döner.
    /// </summary>
    Task<IReadOnlyCollection<LeaveInfoResponse>> QueryLeavesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Avans kayıtlarını listeler. Status verilirse sadece o durumdakiler döner.
    /// </summary>
    Task<IReadOnlyCollection<AdvanceInfoResponse>> QueryAdvancesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// Çalışan performans raporlarını listeler. Yıl/ay verilirse sadece o dönem döner.
    /// </summary>
    Task<IReadOnlyCollection<EmployeePerformanceInfoResponse>> QueryEmployeePerformancesAsync(
        Guid tenantId,
        Guid? branchId,
        int? year,
        int? month,
        int page,
        int pageSize,
        CancellationToken ct = default);

    /// <summary>
    /// İnsan kaynakları özetini döner: çalışan sayısı, izindeki çalışan,
    /// bekleyen izin ve toplam avans tutarları.
    /// </summary>
    Task<HrSummaryResponse> GetHrSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default);
}