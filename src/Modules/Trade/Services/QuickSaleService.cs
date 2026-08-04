using Microsoft.EntityFrameworkCore;
using Npgsql;
using TechSupport.Trade.Contracts.Events;
using TechSupport.Trade.Data;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.Outbox;

namespace TechSupport.Trade.Services;

public sealed class QuickSaleService : IQuickSaleService
{
    private readonly TradeDbContext _db;

    public QuickSaleService(TradeDbContext db) => _db = db;

    public async Task<QuickSale> CreateAsync(CreateQuickSaleRequest request, CancellationToken ct = default)
    {
        if (request.TenantId == Guid.Empty || request.BranchId == Guid.Empty || request.CreatedByUserId == Guid.Empty)
            throw new ArgumentException("Tenant, branch and user are required.");
        if (string.IsNullOrWhiteSpace(request.IdempotencyKey))
            throw new ArgumentException("IdempotencyKey is required.", nameof(request.IdempotencyKey));
        if (request.DiscountAmount < 0)
            throw new ArgumentException("DiscountAmount cannot be negative.", nameof(request.DiscountAmount));
        if (request.PaidAmount is < 0)
            throw new ArgumentException("PaidAmount cannot be negative.", nameof(request.PaidAmount));
        if (request.Items is null || request.Items.Count == 0)
            throw new ArgumentException("At least one sale item is required.", nameof(request.Items));

        var normalizedKey = request.IdempotencyKey.Trim();
        var existing = await _db.QuickSales.Include(x => x.Items)
            .FirstOrDefaultAsync(x => x.TenantId == request.TenantId && x.IdempotencyKey == normalizedKey, ct);
        if (existing is not null)
            return existing;

        var groupedItems = request.Items
            .GroupBy(x => x.StockItemId)
            .Select(x => new CreateQuickSaleLineRequest(x.Key, x.Sum(y => y.Quantity)))
            .ToList();

        if (groupedItems.Any(x => x.StockItemId == Guid.Empty || x.Quantity <= 0))
            throw new ArgumentException("Every stock item and quantity must be valid.", nameof(request.Items));

        var correlationId = Guid.NewGuid();
        var messageId = Guid.NewGuid();
        var sale = new QuickSale
        {
            Id = Guid.NewGuid(),
            TenantId = request.TenantId,
            BranchId = request.BranchId,
            CreatedByUserId = request.CreatedByUserId,
            SaleNumber = $"QS-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid():N}",
            IdempotencyKey = normalizedKey,
            Status = QuickSaleStatus.StockProcessing,
            PaymentMethod = request.PaymentMethod,
            DiscountAmount = request.DiscountAmount,
            PaidAmount = request.PaidAmount ?? 0,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            Items = groupedItems.Select(x => new QuickSaleItem
            {
                Id = Guid.NewGuid(),
                StockItemId = x.StockItemId,
                Quantity = x.Quantity
            }).ToList()
        };

        _db.QuickSales.Add(sale);
        _db.OutboxMessages.Add(TradeOutboxMessage.Create(
            new QuickSaleStockRequested(
                messageId,
                correlationId,
                sale.Id,
                sale.TenantId,
                sale.BranchId,
                sale.IdempotencyKey,
                groupedItems.Select(x => new QuickSaleRequestedItem(x.StockItemId, x.Quantity)).ToList(),
                DateTimeOffset.UtcNow),
            messageId,
            correlationId));

        try
        {
            await _db.SaveChangesAsync(ct);
            return sale;
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        {
            _db.ChangeTracker.Clear();
            return await _db.QuickSales.Include(x => x.Items)
                .SingleAsync(x => x.TenantId == request.TenantId && x.IdempotencyKey == normalizedKey, ct);
        }
    }

    public Task<QuickSale?> GetAsync(Guid tenantId, Guid quickSaleId, CancellationToken ct = default)
        => _db.QuickSales.AsNoTracking().Include(x => x.Items)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == quickSaleId, ct);

    public async Task<IReadOnlyList<QuickSale>> ListAsync(
        Guid tenantId,
        Guid branchId,
        QuickSaleListRequest request,
        CancellationToken ct = default)
    {
        var page = Math.Max(1, request.Page);
        var pageSize = Math.Clamp(request.PageSize, 1, 100);
        return await _db.QuickSales.AsNoTracking().Include(x => x.Items)
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(ct);
    }
}
