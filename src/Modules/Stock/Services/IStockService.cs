using System;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Services;

public interface IStockService
{
    Task<StockItem> CreateAsync(Guid tenantId, Guid? branchId, string sku, string barcode, string name, string? description, string? unit, long initialQuantity, CancellationToken ct = default);
    Task<StockItem?> GetByIdAsync(Guid id, CancellationToken ct = default);
}
