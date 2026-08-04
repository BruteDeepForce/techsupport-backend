using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Services;

public interface IQuickSaleService
{
    Task<QuickSale> CreateAsync(CreateQuickSaleRequest request, CancellationToken ct = default);
    Task<QuickSale?> GetAsync(Guid tenantId, Guid quickSaleId, CancellationToken ct = default);
    Task<IReadOnlyList<QuickSale>> ListAsync(Guid tenantId, Guid branchId, QuickSaleListRequest request, CancellationToken ct = default);
}
