using Microsoft.EntityFrameworkCore;
using TechSupport.Account.Data;
using TechSupport.Account.Domain.Entities;

namespace TechSupport.Account.Services;

public sealed class AccountService : IAccountService
{
    private readonly AccountDbContext _db;

    public AccountService(AccountDbContext db)
    {
        _db = db;
    }

    public async Task<QuickSaleAccountEntry> CreateQuickSaleEntryAsync(CreateQuickSaleAccountEntryRequest request, CancellationToken ct = default)
    {
        var entry = new QuickSaleAccountEntry
        {
            Id = Guid.NewGuid(),
            TenantId = request.TenantId,
            QuickSaleId = request.QuickSaleId,
            BranchId = request.BranchId,
            EntryNumber = $"ACC-{DateTime.UtcNow:yyyyMMddHHmmss}-{Random.Shared.Next(1000, 9999)}",
            EntryType = QuickSaleAccountEntryType.Sale,
            GrossAmount = request.GrossAmount,
            DiscountAmount = request.DiscountAmount,
            NetAmount = request.NetAmount,
            Currency = string.IsNullOrWhiteSpace(request.Currency) ? "TRY" : request.Currency.Trim().ToUpperInvariant(),
            PaymentMethod = request.PaymentMethod,
            Description = request.Description
        };

        _db.QuickSaleAccountEntries.Add(entry);
        await _db.SaveChangesAsync(ct);
        return entry;
    }

    public async Task<IReadOnlyList<QuickSaleAccountEntry>> GetQuickSaleEntriesAsync(Guid tenantId, CancellationToken ct = default)
    {
        return await _db.QuickSaleAccountEntries
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
    }
}
