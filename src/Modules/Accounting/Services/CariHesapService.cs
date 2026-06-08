using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Accounting.RedisService;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace TechSupport.Accounting.Services;

public class CariHesapService : ICariHesapService
{
    private readonly AccountingDbContext _db;
    private readonly IRedisCacheService _cache;

    public CariHesapService(AccountingDbContext db, IRedisCacheService cache)
    {
        _db = db;
        _cache = cache;
    }

    public async Task<CariHesapHareketi?> GetHareketByIdAsync(Guid tenantId, Guid hareketId, CancellationToken ct = default)
    {
        return await _db.CariHesapHareketleri
            .AsNoTracking()
            .Include(x => x.Account)
            .Include(x => x.Invoice)
            .Include(x => x.Payment)
            .FirstOrDefaultAsync(x => x.Id == hareketId && x.TenantId == tenantId, ct);
    }

    public async Task<IReadOnlyList<CariHesapHareketi>> ListHareketlerForTenantAsync(Guid tenantId, int page = 1, int pageSize = 50, CancellationToken ct = default)
    {
        return await _db.CariHesapHareketleri
            .AsNoTracking()
            .Include(x => x.Account)
            .Include(x => x.Invoice)
            .Include(x => x.Payment)
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.IslemTarihi)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(ct);
    }
    public async Task<CariHesapHareketi> CreateHareketAsync(Guid tenantId, Guid? branchId, CreateCariHesapHareketiRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        //using var transaction = await _db.Database.BeginTransactionAsync(ct);
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == request.AccountId && x.TenantId == tenantId, ct);
        if (account == null)
            throw new InvalidOperationException("Account not found for tenant");
        switch (request.HareketTipi)
        {
            case HareketTipi.Borc:
                account.TotalBorc += request.Tutar;
                account.Balance += request.Tutar;
                break;
            case HareketTipi.Alacak:
                account.TotalAlacak += request.Tutar;
                //account.Balance -= request.Tutar;
                break;
            default:
                throw new ArgumentException($"Invalid HareketTipi: {request.HareketTipi}");
        }

        var hareket = new CariHesapHareketi
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            AccountId = request.AccountId,
            CustomerId = request.CustomerId,
            InvoiceId = request.InvoiceId,
            PaymentId = request.PaymentId,
            HareketTipi = request.HareketTipi,
            Borc = request.HareketTipi == HareketTipi.Borc ? request.Tutar : 0,
            Alacak = request.HareketTipi == HareketTipi.Alacak ? request.Tutar : 0,
            Bakiye = 0, // Will be calculated after saving
            Aciklama = request.Aciklama.Trim(),
            ReferansNumarasi = request.ReferansNumarasi?.Trim(),
            BelgeNumarasi = request.BelgeNumarasi?.Trim(),
            IslemTarihi = request.IslemTarihi,
            VadeTarihi = request.VadeTarihi,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };
        await _db.CariHesapHareketleri.AddAsync(hareket, ct);
        var payment = await _db.Payments.FirstOrDefaultAsync(x => x.Id == request.PaymentId, ct);
        if (payment != null)        {
            payment.Status = PaymentStatus.Tamamlandi;
        }
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        account.UpdatedBy = createdBy;
        await _db.SaveChangesAsync(ct);
        //await transaction.CommitAsync(ct);

        //! create edilen hareket olduğu için ilgili keyi invalidate ettim. 
        //! get Ekstre yaparken tekrar Db den çekilecek ve orada Set edilecek.
        // Invalidate cache for the account's movements
        var keys = new Dictionary<string, string>()
        {
            { "key1", $"carihesaplar:hareketler:{tenantId}" }, // Invalidate all movement list caches for tenant
            { "key2", $"carihesaplar:ekstre:{account.Id}:{tenantId}:{request.CustomerId}" },
            { "key3", $"carihesaplar:ListCari:{tenantId}" } // Invalidate this customer's statement cache
        };

        foreach(var key in keys)
        {
            await _cache.RemoveAsync(key.Value);
        }

        return hareket;
    }
    //!beklemeye aldım bu metodu
    [Obsolete("Standbyda şuan bu metod")]
    public async Task<CariHesapHareketi> CreateHareketAsync2(Guid tenantId, Guid? branchId, CreateCariHesapHareketiRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        // Validate account for tenant
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == request.AccountId && x.TenantId == tenantId, ct);

        if (account == null)
            throw new InvalidOperationException("Account not found for tenant");

        // Get current balance for this customer
        var currentBalance = await CalculateCustomerBakiyeAsync(tenantId, request.AccountId, request.CustomerId, ct);

        // Calculate new balance based on movement type
        decimal borc = 0, alacak = 0, yeniBakiye;

        switch (request.HareketTipi)
        {
            case HareketTipi.Borc:
                borc = request.Tutar;
                yeniBakiye = currentBalance + request.Tutar;  // Borc increases balance
                break;
            case HareketTipi.Alacak:
                alacak = request.Tutar;
                yeniBakiye = currentBalance - request.Tutar;  // Alacak decreases balance
                break;
            default:
                throw new ArgumentException($"Invalid HareketTipi: {request.HareketTipi}");
        }

        var hareket = new CariHesapHareketi
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            AccountId = request.AccountId,
            CustomerId = request.CustomerId,
            InvoiceId = request.InvoiceId,
            PaymentId = request.PaymentId,
            HareketTipi = request.HareketTipi,
            Borc = borc,
            Alacak = alacak,
            Bakiye = yeniBakiye,
            Aciklama = request.Aciklama.Trim(),
            ReferansNumarasi = request.ReferansNumarasi?.Trim(),
            BelgeNumarasi = request.BelgeNumarasi?.Trim(),
            IslemTarihi = request.IslemTarihi,
            VadeTarihi = request.VadeTarihi,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };

        await _db.CariHesapHareketleri.AddAsync(hareket, ct);

        // Update tenant-level account totals
        if (request.HareketTipi == HareketTipi.Borc)
        {
            account.TotalBorc += borc;
            account.Balance += borc;
        }
        else if (request.HareketTipi == HareketTipi.Alacak)
        {
            account.TotalAlacak += alacak;
            account.Balance -= alacak;
        }

        account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        account.UpdatedBy = createdBy;

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(account);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);

            if (databaseValues == null)
                throw new InvalidOperationException(
                    "Account was deleted by another user. Please refresh and try again.");

            throw new InvalidOperationException(
                "Another user has modified this account. Please refresh and try again.");
        }

        return hareket;
    }

    public async Task<CariHesapBakiyeResponse> GetBakiyeAsync(Guid tenantId, Guid accountId, Guid customerId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account == null)
            throw new InvalidOperationException($"Account not found: {accountId}");

        var hesaplamalar = await _db.CariHesapHareketleri
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.AccountId == accountId && x.CustomerId == customerId)
            .GroupBy(x => x.CustomerId)
            .Select(g => new
            {
                ToplamBorc = g.Sum(x => x.Borc),
                ToplamAlacak = g.Sum(x => x.Alacak),
                ToplamHareket = g.Count(),
                SonIslemTarihi = g.Max(x => x.IslemTarihi)
            })
            .FirstOrDefaultAsync(ct);

        var toplamBorc = hesaplamalar?.ToplamBorc ?? 0;
        var toplamAlacak = hesaplamalar?.ToplamAlacak ?? 0;

        return new CariHesapBakiyeResponse
        {
            AccountId = accountId,
            CustomerId = customerId,
            AccountName = account.Name,
            AccountNumber = account.AccountNumber,
            Borc = toplamBorc,
            Alacak = toplamAlacak,
            Bakiye = toplamBorc - toplamAlacak,
            ToplamHareket = hesaplamalar?.ToplamHareket ?? 0,
            SonIslemTarihi = hesaplamalar?.SonIslemTarihi
        };
    }

    public async Task<CariHesapEkstreResponse> GetEkstreAsync(Guid tenantId, CariHesapEkstreRequest request, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == request.AccountId && x.TenantId == tenantId, ct);

        if (account == null)
            throw new InvalidOperationException($"Account not found: {request.AccountId}");

        // Get previous balance (before date range)
        decimal oncekiBakiye = 0;
        if (request.BaslangicTarihi.HasValue)
        {
            oncekiBakiye = await _db.CariHesapHareketleri
                .AsNoTracking()
        .Where(x => x.TenantId == tenantId && x.AccountId == request.AccountId && x.CustomerId == request.CustomerId && x.IslemTarihi < request.BaslangicTarihi.Value)
                .SumAsync(x => x.Borc - x.Alacak, ct);
        }

        // Get movements in date range
        var query = _db.CariHesapHareketleri
            .AsNoTracking()
            .Include(x => x.Invoice)
            .Include(x => x.Payment)
            .Where(x => x.TenantId == tenantId && x.AccountId == request.AccountId && x.CustomerId == request.CustomerId);

        if (request.BaslangicTarihi.HasValue)
            query = query.Where(x => x.IslemTarihi >= request.BaslangicTarihi.Value);

        if (request.BitisTarihi.HasValue)
            query = query.Where(x => x.IslemTarihi <= request.BitisTarihi.Value);

        var totalCount = await query.CountAsync(ct);

        var hareketler = await query
            .OrderBy(x => x.IslemTarihi)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(x => new CariHesapHareketiResponse
            {
                Id = x.Id,
                TenantId = x.TenantId,
                AccountId = x.AccountId,
                CustomerId = x.CustomerId,
                InvoiceId = x.InvoiceId,
                InvoiceNumber = x.Invoice != null ? x.Invoice.InvoiceNumber : null,
                PaymentId = x.PaymentId,
                PaymentNumber = x.Payment != null ? x.Payment.PaymentNumber : null,
                HareketTipi = x.HareketTipi,
                Borc = x.Borc,
                Alacak = x.Alacak,
                Bakiye = x.Bakiye,
                Aciklama = x.Aciklama,
                ReferansNumarasi = x.ReferansNumarasi,
                BelgeNumarasi = x.BelgeNumarasi,
                IslemTarihi = x.IslemTarihi,
                VadeTarihi = x.VadeTarihi,
                CreatedAtUtc = x.CreatedAtUtc,
                CreatedBy = x.CreatedBy
            })
            .ToListAsync(ct);

        var toplamBorc = hareketler.Sum(x => x.Borc);
        var toplamAlacak = hareketler.Sum(x => x.Alacak);

        return new CariHesapEkstreResponse
        {
            AccountId = request.AccountId,
            AccountName = account.Name,
            AccountNumber = account.AccountNumber,
            OncekiBakiye = oncekiBakiye,
            ToplamBorc = toplamBorc,
            ToplamAlacak = toplamAlacak,
            GuncelBakiye = oncekiBakiye + toplamBorc - toplamAlacak,
            Hareketler = hareketler,
            ToplamKayit = totalCount,
            Sayfa = request.Page,
            SayfaBoyutu = request.PageSize
        };
    }

    public async Task<IReadOnlyList<CariHesapListItemResponse>> ListCariHesaplarAsync(Guid tenantId, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        var totals = await _db.CariHesapHareketleri
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .GroupBy(x => 1)
            .Select(g => new CariHesapListItemResponse
            {
                Borc = g.Sum(x => x.Borc),
                Alacak = g.Sum(x => x.Alacak),
                Bakiye = g.Sum(x => x.Borc) - g.Sum(x => x.Alacak),
                SonIslemTarihi = g.Max(x => x.IslemTarihi)
            })
            .ToListAsync(ct);

        return totals;




    }

    private async Task<decimal> CalculateCustomerBakiyeAsync(Guid tenantId, Guid accountId, Guid customerId, CancellationToken ct)
    {
        var result = await _db.CariHesapHareketleri
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.AccountId == accountId && x.CustomerId == customerId)
            .GroupBy(x => x.CustomerId)
            .Select(g => new
            {
                ToplamBorc = g.Sum(x => x.Borc),
                ToplamAlacak = g.Sum(x => x.Alacak)
            })
            .FirstOrDefaultAsync(ct);

        return (result?.ToplamBorc ?? 0) - (result?.ToplamAlacak ?? 0);
    }
}
