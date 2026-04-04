using System;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Stock.DTO;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Services;

public interface IStockService
{
    Task<StockItem> CreateAsync(Guid tenantId, Guid? branchId, Guid categoryId, string sku, string barcode, string name, string? description, string? unit, long initialQuantity, CancellationToken ct = default);
    Task<StockItem?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<StockItemListDto>> GetAllAsync(Guid tenantId, CancellationToken ct = default);
    Task<IReadOnlyList<StockItemListDto>> GetAllByCategoryId(Guid tenantId, Guid categoryId, CancellationToken ct = default);
}
