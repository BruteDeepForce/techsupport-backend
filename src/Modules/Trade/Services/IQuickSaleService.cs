using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Services;

public interface IQuickSaleService
{
    Task<QuickSale> CreateAsync(CreateQuickSaleRequest request, CancellationToken ct = default);
    Task<IReadOnlyList<QuickSale>> GetAllAsync(Guid tenantId, CancellationToken ct = default);
}
