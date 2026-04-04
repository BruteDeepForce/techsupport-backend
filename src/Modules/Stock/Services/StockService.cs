using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;
using TechSupport.Stock.DTO;

namespace TechSupport.Stock.Services;

public class StockService : IStockService
{
    private readonly StockDbContext _db;

    public StockService(StockDbContext db)
    {
        _db = db;
    }

    public async Task<StockItem> CreateAsync(Guid tenantId, Guid? branchId, Guid categoryId, string sku, string barcode,
    string name, string? description, string? unit, long initialQuantity, CancellationToken ct = default)
    {
        var categoryExists = await _db.StockCategories
            .AnyAsync(x => x.TenantId == tenantId && x.Id == categoryId, ct);
        if (!categoryExists)
            throw new InvalidOperationException($"Category with id '{categoryId}' does not exist for tenant {tenantId}");

        var existing = await _db.StockItems
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && (x.Sku == sku || x.Barcode == barcode), ct);
        if (existing != null)
        {
            if (existing.Sku == sku)
                throw new InvalidOperationException($"SKU '{sku}' already exists for tenant {tenantId}");
            if (existing.Barcode == barcode)
                throw new InvalidOperationException($"Barcode '{barcode}' already exists for tenant {tenantId}");
            // fallback
            throw new InvalidOperationException($"Stock item conflict for tenant {tenantId}");
        }

        var item = new StockItem
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            CategoryId = categoryId,
            Sku = sku,
            Barcode = barcode,
            Name = name,
            Description = description,
            Unit = unit,
            CreatedAtUtc = DateTime.UtcNow,
        };

        var balance = new StockBalance
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            StockItemId = item.Id,
            BranchId = branchId,
            QuantityAvailable = initialQuantity,
            QuantityReserved = 0
        };

        // add both entities and save in one transaction
        await using var tx = await _db.Database.BeginTransactionAsync(ct);
        try
        {
            _db.StockItems.Add(item);
            _db.StockBalances.Add(balance);
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch (DbUpdateException dbEx)
        {
            // rollback first
            await tx.RollbackAsync(ct);

            // Try to detect unique constraint violation (Postgres 23505)
            var inner = dbEx.InnerException;
            try
            {
                // Prefer PostgresException if available
                if (inner is Npgsql.PostgresException pg && pg.SqlState == "23505")
                {
                    // conflict - find which field collides
                    var conflict = await _db.StockItems.FirstOrDefaultAsync(x => x.TenantId == tenantId && (x.Sku == sku || x.Barcode == barcode), ct);
                    if (conflict != null)
                    {
                        if (conflict.Sku == sku)
                            throw new InvalidOperationException($"SKU '{sku}' already exists for tenant {tenantId}");
                        if (conflict.Barcode == barcode)
                            throw new InvalidOperationException($"Barcode '{barcode}' already exists for tenant {tenantId}");
                    }

                    // if we couldn't determine, return a generic friendly message
                    throw new InvalidOperationException("A uniqueness constraint was violated when creating the stock item.");
                }
            }
            catch (InvalidOperationException)
            {
                // rethrow specific friendly errors
                throw;
            }

            // Not a Postgres uniqueness issue - rethrow original exception
            throw;
        }

        return item;
    }

    public async Task<StockItem?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        return await _db.StockItems.FirstOrDefaultAsync(x => x.Id == id, ct);
    }

    public async Task<IReadOnlyList<StockItemListDto>> GetAllAsync(Guid tenantId, CancellationToken ct = default)
    {
        return await _db.StockItems.AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .Select(x => new StockItemListDto(
                x.Id,
                x.CategoryId,
                x.Category != null ? x.Category.Name : null,
                x.Sku,
                x.Barcode,
                x.Name,
                x.Description,
                x.Unit,
                x.UnitPrice,
                x.Balances.Sum(b => b.QuantityAvailable),
                x.Balances.Sum(b => b.QuantityReserved),
                x.CreatedAtUtc
            ))
            .ToListAsync(ct);
    }
    public async Task<IReadOnlyList<StockItemListDto>> GetAllByCategoryId(Guid tenantId, Guid categoryId, CancellationToken ct = default)
    {
        return await _db.StockItems.AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.CategoryId == categoryId)
            .Select(x => new StockItemListDto(
                x.Id,
                x.CategoryId,
                x.Category != null ? x.Category.Name : null,
                x.Sku,
                x.Barcode,
                x.Name,
                x.Description,
                x.Unit,
                x.UnitPrice,
                x.Balances.Sum(b => b.QuantityAvailable),
                x.Balances.Sum(b => b.QuantityReserved),
                x.CreatedAtUtc
            ))
            .ToListAsync(ct);
    }
}
