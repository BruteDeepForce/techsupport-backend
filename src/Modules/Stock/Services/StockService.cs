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

    public async Task<StockItem> CreateAsync(Guid tenantId, Guid? branchId, CreateItemDTO dto, CancellationToken ct = default)
    {
        var categoryExists = await _db.StockCategories
            .AnyAsync(x => x.TenantId == tenantId && x.Id == dto.CategoryId, ct);
        if (!categoryExists)
            throw new InvalidOperationException($"Category with id '{dto.CategoryId}' does not exist for tenant {tenantId}");

        var existing = await _db.StockItems
            .FirstOrDefaultAsync(x => x.TenantId == tenantId
                && (x.Sku == dto.Sku
                    || x.Barcode == dto.Barcode
                    || (dto.DeviceId.HasValue && x.DeviceId == dto.DeviceId)
                    || (!string.IsNullOrWhiteSpace(dto.ImeiOrSerial) && x.ImeiOrSerial == dto.ImeiOrSerial.Trim())), ct);
        if (existing != null)
        {
            if (existing.Sku == dto.Sku)
                throw new InvalidOperationException($"SKU '{dto.Sku}' already exists for tenant {tenantId}");
            if (existing.Barcode == dto.Barcode)
                throw new InvalidOperationException($"Barcode '{dto.Barcode}' already exists for tenant {tenantId}");
            if (dto.DeviceId.HasValue && existing.DeviceId == dto.DeviceId)
                throw new InvalidOperationException($"Device '{dto.DeviceId}' already has a stock item for tenant {tenantId}");
            if (!string.IsNullOrWhiteSpace(dto.ImeiOrSerial) && existing.ImeiOrSerial == dto.ImeiOrSerial.Trim())
                throw new InvalidOperationException($"IMEI/serial '{dto.ImeiOrSerial}' already exists for tenant {tenantId}");
            // fallback
            throw new InvalidOperationException($"Stock item conflict for tenant {tenantId}");
        }

        var item = new StockItem
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            DeviceId = dto.DeviceId,
            CategoryId = dto.CategoryId,
            Sku = dto.Sku.Trim(),
            ImeiOrSerial = dto.ImeiOrSerial?.Trim(),
            Barcode = dto.Barcode.Trim(),
            Name = dto.Name.Trim(),
            Description = dto.Description?.Trim(),
            Unit = dto.Unit?.Trim(),
            UnitPrice = dto.UnitPrice
        };

        var balance = new StockBalance
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            StockItemId = item.Id,
            BranchId = branchId,
            QuantityAvailable = dto.InitialQuantity,
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
        catch (DbUpdateException dbEx) //! güzel rollback uyguladık
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
                    var conflict = await _db.StockItems.FirstOrDefaultAsync(x => x.TenantId == tenantId && (x.Sku == dto.Sku || x.Barcode == dto.Barcode), ct);
                    if (conflict != null)
                    {
                        if (conflict.Sku == dto.Sku)
                            throw new InvalidOperationException($"SKU '{dto.Sku}' already exists for tenant {tenantId}");
                        if (conflict.Barcode == dto.Barcode)
                            throw new InvalidOperationException($"Barcode '{dto.Barcode}' already exists for tenant {tenantId}");
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

    public async Task<StockItem> StockInAsync(Guid tenantId, Guid? branchId, Guid? userId, Guid stockItemId, StockInDTO dto, CancellationToken ct = default)
    {
        if (dto.Quantity <= 0)
            throw new InvalidOperationException("Stock-in quantity must be greater than zero.");

        var item = await _db.StockItems
            .Include(x => x.Balances)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == stockItemId, ct);

        if (item is null)
            throw new InvalidOperationException($"Stock item '{stockItemId}' does not exist for tenant {tenantId}.");

        var balance = item.Balances.FirstOrDefault(x => x.TenantId == tenantId && x.BranchId == branchId);
        if (balance is null)
        {
            balance = new StockBalance
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                StockItemId = item.Id,
                BranchId = branchId,
                QuantityAvailable = 0,
                QuantityReserved = 0
            };
            _db.StockBalances.Add(balance);
            item.Balances.Add(balance);
        }

        balance.QuantityAvailable += dto.Quantity;
        item.UpdatedAtUtc = DateTime.UtcNow;

        _db.StockTransactions.Add(new StockTransaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            StockItemId = item.Id,
            BranchId = branchId,
            UserId = userId,
            Quantity = dto.Quantity,
            Type = StockTransactionType.Adjust,
            Reference = string.IsNullOrWhiteSpace(dto.Reference)
                ? "Stock in"
                : dto.Reference.Trim(),
            Barcode = item.Barcode,
            CreatedAtUtc = DateTime.UtcNow
        });

        await _db.SaveChangesAsync(ct);
        return item;
    }

    public async Task<StockItem?> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct = default)
    {
        return await _db.StockItems
            .AsNoTracking()
            .Include(x => x.Balances)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);
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
                x.CreatedAtUtc,
                x.DeviceId
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
                x.CreatedAtUtc,
                x.DeviceId
            ))
            .ToListAsync(ct);
    }
}
