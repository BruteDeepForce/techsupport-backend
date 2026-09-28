using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Contracts.Services;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Services;

public sealed class InventoryStockItemWriter : IInventoryStockItemWriter
{
    private readonly StockDbContext _db;

    public InventoryStockItemWriter(StockDbContext db)
    {
        _db = db;
    }

    [Obsolete("  System.InvalidOperationException: A stock item already exists with the same SKU, barcode, device or IMEI/serial. HATASI ALDIK CHECK")]
    public async Task<InventoryStockItemResult> CreateForDeviceAsync(InventoryStockItemCreateRequest request, CancellationToken cancellationToken = default)
    {
        if (request.TenantId == Guid.Empty) throw new ArgumentException("TenantId is required.", nameof(request));
        if (request.BranchId == Guid.Empty) throw new ArgumentException("BranchId is required.", nameof(request));
        if (request.DeviceId == Guid.Empty) throw new ArgumentException("DeviceId is required.", nameof(request));
        if (request.CategoryId == Guid.Empty) throw new InvalidOperationException("CategoryId is required.");
        if (request.Quantity <= 0) throw new InvalidOperationException("Quantity must be greater than zero.");
        if (request.UnitPrice <= 0) throw new InvalidOperationException("UnitPrice must be greater than zero.");

        var sku = RequiredTrim(request.Sku, nameof(request.Sku));
        var imeiOrSerial = RequiredTrim(request.ImeiOrSerial, nameof(request.ImeiOrSerial));
        var barcode = RequiredTrim(request.Barcode, nameof(request.Barcode));
        var name = RequiredTrim(request.Name, nameof(request.Name));
        var unit = RequiredTrim(request.Unit, nameof(request.Unit));

        var categoryExists = await _db.StockCategories
            .AnyAsync(x => x.TenantId == request.TenantId && x.Id == request.CategoryId, cancellationToken);
        if (!categoryExists)
            throw new InvalidOperationException($"Category with id '{request.CategoryId}' does not exist for tenant {request.TenantId}");

        var existingStockItem = await _db.StockItems
            .FirstOrDefaultAsync(x => x.TenantId == request.TenantId
                && (x.Sku == sku
                    || x.Barcode == barcode
                    || x.DeviceId == request.DeviceId
                    || x.ImeiOrSerial == imeiOrSerial), cancellationToken);
        if (existingStockItem is not null)
            throw new InvalidOperationException("A stock item already exists with the same SKU, barcode, device or IMEI/serial.");

        var stockItemId = Guid.NewGuid();
        var stockItem = new StockItem
        {
            Id = stockItemId,
            TenantId = request.TenantId,
            BranchId = request.BranchId,
            DeviceId = request.DeviceId,
            CategoryId = request.CategoryId,
            Sku = sku,
            ImeiOrSerial = imeiOrSerial,
            Barcode = barcode,
            Name = name,
            Description = request.Description?.Trim(),
            Unit = unit,
            UnitPrice = request.UnitPrice,
            Balances = new List<StockBalance>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    TenantId = request.TenantId,
                    BranchId = request.BranchId,
                    StockItemId = stockItemId,
                    QuantityAvailable = request.Quantity,
                    QuantityReserved = 0
                }
            }
        };

        await _db.StockItems.AddAsync(stockItem, cancellationToken);
        await _db.SaveChangesAsync(cancellationToken);

        return new InventoryStockItemResult(stockItem.Id, request.DeviceId, request.Quantity);
    }

    private static string RequiredTrim(string value, string name)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException($"{name} is required.");

        return value.Trim();
    }
}
