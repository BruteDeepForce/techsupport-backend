using System;
using System.ComponentModel.DataAnnotations;

namespace TechSupport.Accounting.Domain.Entities;

public class Payment
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid AccountId { get; set; }
    public Account? Account { get; set; }
    
    public Guid CustomerId { get; set; }
    
    public Guid? InvoiceId { get; set; }
    public Invoice? Invoice { get; set; }
    
    public string PaymentNumber { get; set; } = string.Empty;
    public PaymentMethod Method { get; set; } = PaymentMethod.Nakit;
    public PaymentStatus Status { get; set; } = PaymentStatus.Beklemede;
    
    public decimal Amount { get; set; }
    public decimal FeeAmount { get; set; }
    public decimal NetAmount { get; set; }
    
    public string? ReferenceNumber { get; set; }
    public string? Notes { get; set; }
    
    public DateTimeOffset PaymentDate { get; set; }
    public DateTimeOffset? ProcessedAtUtc { get; set; }
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public bool IsDeleted { get; set; }
    
    // Concurrency token for optimistic locking
    [Timestamp]
    [ConcurrencyCheck]
    public byte[]? RowVersion { get; set; }
    
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

public enum PaymentMethod
{
    Nakit,         // Cash
    KrediKarti,    // Credit Card
    BankaHavalesi, // Bank Transfer
    Cek,           // Check
    Senet,         // Promissory Note
    Diger          // Other
}

public enum PaymentStatus
{
    Beklemede,    // Pending
    Islemede,     // Processing
    Tamamlandi,   // Completed
    Basarisiz,    // Failed
    IadeEdildi    // Refunded
}
