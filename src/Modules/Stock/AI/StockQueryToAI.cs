using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Contracts.AI;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.AI;

/// <summary>
/// AI modülünün stok verisini okumasını sağlayan implementasyon.
/// </summary>
public sealed class StockQueryToAI : IStockQueryToAI
{
    private const int CriticalStockThreshold = 3;

    private readonly StockDbContext _db;

    public StockQueryToAI(StockDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyCollection<StockItemInfoResponse>> QueryStockItemsAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.StockItems
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x =>
                EF.Functions.ILike(x.Name, $"%{term}%") ||
                EF.Functions.ILike(x.Sku, $"%{term}%") ||
                (x.Category != null && EF.Functions.ILike(x.Category.Name, $"%{term}%")));
        }

        return await query
            .OrderBy(x => x.Name)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new StockItemInfoResponse(
                x.Id,
                x.Sku,
                x.Name,
                x.Description,
                x.Category != null ? x.Category.Name : null,
                x.Unit,
                x.UnitPrice,
                x.Balances
                    .Where(b => !branchId.HasValue || b.BranchId == branchId)
                    .Sum(b => b.QuantityAvailable),
                x.Balances
                    .Where(b => !branchId.HasValue || b.BranchId == branchId)
                    .Sum(b => b.QuantityReserved)))
            .ToListAsync(ct);
    }

    public async Task<StockSummaryResponse> GetStockSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default)
    {
        var items = await _db.StockItems
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .Select(x => new
            {
                x.Id,
                Available = x.Balances
                    .Where(b => !branchId.HasValue || b.BranchId == branchId)
                    .Sum(b => b.QuantityAvailable),
                Reserved = x.Balances
                    .Where(b => !branchId.HasValue || b.BranchId == branchId)
                    .Sum(b => b.QuantityReserved)
            })
            .ToListAsync(ct);

        var pendingReservations = await _db.StockReservations
            .AsNoTracking()
            .CountAsync(
                x => x.TenantId == tenantId
                     && (!branchId.HasValue || x.BranchId == branchId)
                     && x.Status == StockReservationStatus.Pending,
                ct);

        return new StockSummaryResponse(
            items.Count,
            items.Count(x => x.Available <= CriticalStockThreshold),
            items.Sum(x => x.Available),
            items.Sum(x => x.Reserved),
            pendingReservations);
    }

    public async Task<IReadOnlyCollection<StockReservationInfoResponse>> QueryStockReservationsAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.StockReservations
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (Enum.TryParse<StockReservationStatus>(status.Trim(), ignoreCase: true, out var parsed))
            {
                query = query.Where(x => x.Status == parsed);
            }
        }

        return await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new StockReservationInfoResponse(
                x.Id,
                x.StockItemId,
                x.StockItem != null ? x.StockItem.Sku : string.Empty,
                x.StockItem != null ? x.StockItem.Name : string.Empty,
                x.Quantity,
                x.Status.ToString(),
                x.OperationId,
                x.TechnicianUserId,
                x.CreatedAtUtc))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<StockTransactionInfoResponse>> QueryStockTransactionsAsync(
        Guid tenantId,
        Guid? branchId,
        DateTimeOffset? from,
        DateTimeOffset? to,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.StockTransactions
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (from.HasValue)
        {
            var fromUtc = from.Value.UtcDateTime;
            query = query.Where(x => x.CreatedAtUtc >= fromUtc);
        }

        if (to.HasValue)
        {
            var toUtc = to.Value.UtcDateTime;
            query = query.Where(x => x.CreatedAtUtc <= toUtc);
        }

        return await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new StockTransactionInfoResponse(
                x.Id,
                x.StockItemId,
                x.StockItem != null ? x.StockItem.Sku : string.Empty,
                x.StockItem != null ? x.StockItem.Name : string.Empty,
                x.Quantity,
                x.Type.ToString(),
                x.OperationId,
                x.Reference,
                x.CreatedAtUtc))
            .ToListAsync(ct);
    }

    private static (int Page, int PageSize) NormalizePaging(int page, int pageSize)
    {
        var safePage = page < 1 ? 1 : page;
        var safePageSize = pageSize switch
        {
            < 1 => 20,
            > 200 => 200,
            _ => pageSize
        };

        return (safePage, safePageSize);
    }
}