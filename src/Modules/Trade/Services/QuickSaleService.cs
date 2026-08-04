using Microsoft.EntityFrameworkCore;
using TechSupport.Account.Services;
using TechSupport.Stock.Services;
using TechSupport.Trade.Data;
using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Services;

public sealed class QuickSaleService : IQuickSaleService
{
    private readonly TradeDbContext _db;
    private readonly IStockService _stockService;
    private readonly IAccountService _accountService;

    public QuickSaleService(TradeDbContext db, IStockService stockService, IAccountService accountService)
    {
        _db = db;
        _stockService = stockService;
        _accountService = accountService;
    }

    public async Task<QuickSale> CreateAsync(CreateQuickSaleRequest request, CancellationToken ct = default)
    {
        if (request.Lines == null || request.Lines.Count == 0)
            throw new InvalidOperationException("At least one quick sale line is required");

        var stockItems = new Dictionary<Guid, TechSupport.Stock.Domain.Entities.StockItem>();
        foreach (var line in request.Lines)
        {
            if (line.Quantity <= 0)
                throw new InvalidOperationException("Line quantity must be greater than zero");

            var stockItem = await _stockService.GetByIdAsync(line.StockItemId, ct)
                ?? throw new InvalidOperationException($"Stock item '{line.StockItemId}' not found");
            stockItems[line.StockItemId] = stockItem;
        }

        decimal subtotal = 0;
        var quickSale = new QuickSale
        {
            Id = Guid.NewGuid(),
            TenantId = request.TenantId,
            BranchId = request.BranchId,
            SaleNumber = $"QS-{DateTime.UtcNow:yyyyMMddHHmmss}-{Random.Shared.Next(1000, 9999)}",
            DiscountAmount = request.DiscountAmount < 0 ? 0 : request.DiscountAmount,
            Currency = string.IsNullOrWhiteSpace(request.Currency) ? "TRY" : request.Currency.Trim().ToUpperInvariant(),
            PaymentMethod = string.IsNullOrWhiteSpace(request.PaymentMethod) ? "Cash" : request.PaymentMethod.Trim(),
            Note = request.Note,
            Status = QuickSaleStatus.Completed,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        foreach (var line in request.Lines)
        {
            var item = stockItems[line.StockItemId];
            var unitPrice = line.UnitPriceOverride.HasValue && line.UnitPriceOverride.Value > 0
                ? line.UnitPriceOverride.Value
                : 0m;
            var lineTotal = unitPrice * line.Quantity;
            subtotal += lineTotal;

            quickSale.Lines.Add(new QuickSaleLine
            {
                Id = Guid.NewGuid(),
                QuickSaleId = quickSale.Id,
                StockItemId = item.Id,
                ProductName = item.Name,
                Sku = item.Sku,
                UnitPrice = unitPrice,
                Quantity = line.Quantity,
                LineTotal = lineTotal
            });
        }

        quickSale.SubtotalAmount = subtotal;
        quickSale.TotalAmount = Math.Max(0, subtotal - quickSale.DiscountAmount);
        quickSale.PaidAmount = request.PaidAmount <= 0 ? quickSale.TotalAmount : request.PaidAmount;

        await using var tx = await _db.Database.BeginTransactionAsync(ct);
        _db.QuickSales.Add(quickSale);
        await _db.SaveChangesAsync(ct);

        foreach (var line in quickSale.Lines)
        {
            await _stockService.ConsumeForQuickSaleAsync(
                request.TenantId,
                request.BranchId,
                quickSale.Id,
                line.StockItemId,
                line.Quantity,
                $"Quick sale {quickSale.SaleNumber}",
                ct);
        }

        await _accountService.CreateQuickSaleEntryAsync(new CreateQuickSaleAccountEntryRequest(
            request.TenantId,
            quickSale.Id,
            request.BranchId,
            quickSale.SubtotalAmount,
            quickSale.DiscountAmount,
            quickSale.TotalAmount,
            quickSale.Currency,
            quickSale.PaymentMethod,
            $"Quick sale {quickSale.SaleNumber}"), ct);

        await tx.CommitAsync(ct);
        return quickSale;
    }

    public async Task<IReadOnlyList<QuickSale>> GetAllAsync(Guid tenantId, CancellationToken ct = default)
    {
        return await _db.QuickSales
            .AsNoTracking()
            .Include(x => x.Lines)
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
    }
}
