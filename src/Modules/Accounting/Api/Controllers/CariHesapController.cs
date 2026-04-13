using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Query;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.RedisService;
using TechSupport.Accounting.Services;

namespace TechSupport.Accounting.Api.Controllers;

[ApiController]
[Route("api/accounting/cari-hesaplar")]
[Authorize]
public class CariHesapController : ControllerBase
{
    private readonly ICariHesapService _cariHesapService;
    private readonly IRedisCacheService _redisCache;

    public CariHesapController(ICariHesapService cariHesapService, IRedisCacheService redisCache)
    {
        _cariHesapService = cariHesapService;
        _redisCache = redisCache;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<CariHesapListItemResponse>>> ListCariHesaplar(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });
        //!CACHLENDİ
        var key = $"carihesaplar:ListCari:{tenantId}";
        var cached = await _redisCache.GetAsync<IReadOnlyList<CariHesapListItemResponse>>(key);
        if (cached != null)
            return Ok(cached);


        var result = await _cariHesapService.ListCariHesaplarAsync(tenantId, page, pageSize);
        await _redisCache.RemoveAsync($"carihesaplar:ListCari:{tenantId}"); // Invalidate cache when list is updated
        await _redisCache.SetAsync(key, result, TimeSpan.FromMinutes(5));
        return Ok(result);
    }

    [HttpGet("hareketler")]
    public async Task<ActionResult<IReadOnlyList<CariHesapHareketiResponse>>> ListAllHareketler(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });
        //!CACHLENDİ SERVİSTE INVALID GEREKIRSE YAPILIYOR.
        var key = $"carihesaplar:hareketler:{tenantId}";
        var cached = await _redisCache.GetAsync<IReadOnlyList<CariHesapHareketiResponse>>(key);
        if (cached != null)
            return Ok(cached);

        var hareketler = await _cariHesapService.ListHareketlerForTenantAsync(tenantId, page, pageSize);

        var result = hareketler.Select(hareket => new CariHesapHareketiResponse
        {
            Id = hareket.Id,
            TenantId = hareket.TenantId,
            AccountId = hareket.AccountId,
            CustomerId = hareket.CustomerId,
            AccountName = hareket.Account?.Name,
            AccountNumber = hareket.Account?.AccountNumber,
            InvoiceId = hareket.InvoiceId,
            InvoiceNumber = hareket.Invoice?.InvoiceNumber,
            PaymentId = hareket.PaymentId,
            PaymentNumber = hareket.Payment?.PaymentNumber,
            HareketTipi = hareket.HareketTipi,
            Borc = hareket.Borc,
            Alacak = hareket.Alacak,
            Bakiye = hareket.Bakiye,
            Aciklama = hareket.Aciklama,
            ReferansNumarasi = hareket.ReferansNumarasi,
            BelgeNumarasi = hareket.BelgeNumarasi,
            IslemTarihi = hareket.IslemTarihi,
            VadeTarihi = hareket.VadeTarihi,
            CreatedAtUtc = hareket.CreatedAtUtc,
            CreatedBy = hareket.CreatedBy
        }).ToList();
        await _redisCache.RemoveAsync($"carihesaplar:hareketler:{tenantId}"); // Invalidate list cache when movements are listed
        await _redisCache.SetAsync(key, result, TimeSpan.FromMinutes(5));

        return Ok(result);
    }

    [HttpGet("{accountId:guid}/bakiye")]
    public async Task<ActionResult<CariHesapBakiyeResponse>> GetBakiye(Guid accountId, [FromQuery] Guid customerId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        if (customerId == Guid.Empty)
            return BadRequest(new { error = "customerId is required" });

        try
        {
            var result = await _cariHesapService.GetBakiyeAsync(tenantId, accountId, customerId);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { error = ex.Message });
        }
    }
    [HttpPost("{accountId:guid}/ekstre")]
    public async Task<ActionResult<CariHesapEkstreResponse>> Ekstre(
        Guid accountId,
        [FromBody] CariHesapEkstreRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        if (request == null)
            return BadRequest(new { error = "Request body is required" });

        // Ensure accountId from route is authoritative
        request.AccountId = accountId;

        if (request.CustomerId == Guid.Empty)
            return BadRequest(new { error = "customerId is required in request body" });
        //!CACHLENDİ  SERVISTE INVALID GEREKIRSE YAPILIYOR.
        var key = $"carihesaplar:ekstre:{accountId}:{tenantId}:{request.CustomerId}";
        var response = await _redisCache.GetAsync<CariHesapEkstreResponse>(key);
        if (response is not null)
        {
            //! REDIS TEST
            Console.WriteLine("Cache GET for key: " + key);
            return Ok(response);
        }

        try
        {
            var result = await _cariHesapService.GetEkstreAsync(tenantId, request);
            await _redisCache.RemoveAsync(key);
            await _redisCache.SetAsync(key, result, TimeSpan.FromMinutes(5));
            //! REDIS TEST
            Console.WriteLine("Cache SET for key: " + key);

            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { error = ex.Message });
        }
    }

    [HttpPost("hareketler/create")]
    public async Task<ActionResult<CariHesapHareketiResponse>> CreateHareket(

        [FromBody] CreateCariHesapHareketiRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var branchId = GetBranchIdFromClaims();

            var hareket = await _cariHesapService.CreateHareketAsync(tenantId, branchId, request, User.Identity?.Name);

            var response = new CariHesapHareketiResponse
            {
                Id = hareket.Id,
                TenantId = hareket.TenantId,
                AccountId = hareket.AccountId,
                CustomerId = hareket.CustomerId,
                InvoiceId = hareket.InvoiceId,
                PaymentId = hareket.PaymentId,
                HareketTipi = hareket.HareketTipi,
                Borc = hareket.Borc,
                Alacak = hareket.Alacak,
                Bakiye = hareket.Bakiye,
                Aciklama = hareket.Aciklama,
                ReferansNumarasi = hareket.ReferansNumarasi,
                BelgeNumarasi = hareket.BelgeNumarasi,
                IslemTarihi = hareket.IslemTarihi,
                VadeTarihi = hareket.VadeTarihi,
                CreatedAtUtc = hareket.CreatedAtUtc,
                CreatedBy = hareket.CreatedBy
            };

            // Return location of the created movement by id
            return CreatedAtAction(nameof(GetHareketById), new { hareketId = response.Id }, response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("hareketler/{hareketId:guid}")]
    public async Task<ActionResult<CariHesapHareketiResponse>> GetHareketById(Guid hareketId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var hareket = await _cariHesapService.GetHareketByIdAsync(tenantId, hareketId);
        if (hareket == null)
            return NotFound();

        return Ok(new CariHesapHareketiResponse
        {
            Id = hareket.Id,
            TenantId = hareket.TenantId,
            AccountId = hareket.AccountId,
            CustomerId = hareket.CustomerId,
            AccountName = hareket.Account?.Name,
            AccountNumber = hareket.Account?.AccountNumber,
            InvoiceId = hareket.InvoiceId,
            InvoiceNumber = hareket.Invoice?.InvoiceNumber,
            PaymentId = hareket.PaymentId,
            PaymentNumber = hareket.Payment?.PaymentNumber,
            HareketTipi = hareket.HareketTipi,
            Borc = hareket.Borc,
            Alacak = hareket.Alacak,
            Bakiye = hareket.Bakiye,
            Aciklama = hareket.Aciklama,
            ReferansNumarasi = hareket.ReferansNumarasi,
            BelgeNumarasi = hareket.BelgeNumarasi,
            IslemTarihi = hareket.IslemTarihi,
            VadeTarihi = hareket.VadeTarihi,
            CreatedAtUtc = hareket.CreatedAtUtc,
            CreatedBy = hareket.CreatedBy
        });
    }


    private Guid GetTenantIdFromClaims()
    {
        var tenantIdClaim = User.FindFirst("tenantId")
            ?? User.FindFirst("tenant_id");
        return tenantIdClaim != null ? Guid.Parse(tenantIdClaim.Value) : Guid.Empty;
    }
    private Guid? GetBranchIdFromClaims()
    {
        var branchIdClaim = User.FindFirst("branchId")
            ?? User.FindFirst("branch_id");
        return branchIdClaim != null ? Guid.Parse(branchIdClaim.Value) : null;
    }
}
