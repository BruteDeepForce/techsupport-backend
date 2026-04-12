using System;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.DTO;

// ==================== CariHesap DTOs ====================

/// <summary>
/// DTO for creating a new ledger entry (Cari Hesap Hareketi)
/// </summary>
public class CreateCariHesapHareketiRequest
{
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public HareketTipi HareketTipi { get; set; }
    public decimal Tutar { get; set; }  // Amount (will be split to Borc/Alacak based on type)
    public string Aciklama { get; set; } = string.Empty;
    public string? ReferansNumarasi { get; set; }
    public string? BelgeNumarasi { get; set; }
    public DateTimeOffset IslemTarihi { get; set; }
    public DateTimeOffset? VadeTarihi { get; set; }
    public Guid? InvoiceId { get; set; }
    public Guid? PaymentId { get; set; }
}
public sealed record CreateCariHesapHareketiRequestV2(
     Guid AccountId,
    Guid CustomerId,
    HareketTipi HareketTipi,
    decimal borc,  // Amount (will be split to Borc/Alacak based on type)
    decimal alacak,
    string Aciklama = "",
    string? ReferansNumarasi = null,
    string? BelgeNumarasi = null,
    DateTimeOffset IslemTarihi = default,
    DateTimeOffset? VadeTarihi = null,
    Guid? InvoiceId = null,
    Guid? PaymentId = null
);

/// <summary>
/// DTO for Cari Hesap Hareketi response
/// </summary>
public class CariHesapHareketiResponse
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public string? AccountName { get; set; }
    public string? AccountNumber { get; set; }
    public Guid? InvoiceId { get; set; }
    public string? InvoiceNumber { get; set; }
    public Guid? PaymentId { get; set; }
    public string? PaymentNumber { get; set; }
    public HareketTipi HareketTipi { get; set; }
    public decimal Borc { get; set; }
    public decimal Alacak { get; set; }
    public decimal Bakiye { get; set; }
    public string Aciklama { get; set; } = string.Empty;
    public string? ReferansNumarasi { get; set; }
    public string? BelgeNumarasi { get; set; }
    public DateTimeOffset IslemTarihi { get; set; }
    public DateTimeOffset? VadeTarihi { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public string? CreatedBy { get; set; }
}

/// <summary>
/// DTO for Cari Hesap Ekstre (Account Statement) request
/// </summary>
public class CariHesapEkstreRequest
{
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public DateTimeOffset? BaslangicTarihi { get; set; }
    public DateTimeOffset? BitisTarihi { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 50;
}

/// <summary>
/// DTO for Cari Hesap Ekstre (Account Statement) response
/// </summary>
public class CariHesapEkstreResponse
{
    public Guid AccountId { get; set; }
    public string? AccountName { get; set; }
    public string? AccountNumber { get; set; }
    public decimal OncekiBakiye { get; set; }  // Previous balance
    public decimal ToplamBorc { get; set; }   // Total debit
    public decimal ToplamAlacak { get; set; } // Total credit
    public decimal GuncelBakiye { get; set; } // Current balance
    public IReadOnlyList<CariHesapHareketiResponse> Hareketler { get; set; } = Array.Empty<CariHesapHareketiResponse>();
    public int ToplamKayit { get; set; }
    public int Sayfa { get; set; }
    public int SayfaBoyutu { get; set; }
}

/// <summary>
/// DTO for Cari Hesap Bakiye response
/// </summary>
public class CariHesapBakiyeResponse
{
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public string? AccountName { get; set; }
    public string? AccountNumber { get; set; }
    public decimal Borc { get; set; }      // Total debit (Alacak to customer)
    public decimal Alacak { get; set; }    // Total credit (customer paid)
    public decimal Bakiye { get; set; }    // Current balance (Borc - Alacak)
    public int ToplamHareket { get; set; } // Total transactions
    public DateTimeOffset? SonIslemTarihi { get; set; }
}

/// <summary>
/// DTO for listing Cari Hesap accounts with balance
/// </summary>
public class CariHesapListItemResponse
{
    public decimal Borc { get; set; }
    public decimal Alacak { get; set; }
    public decimal Bakiye { get; set; }
    public DateTimeOffset? SonIslemTarihi { get; set; }
}
