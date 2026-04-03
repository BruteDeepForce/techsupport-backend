using System;

namespace TechSupport.Accounting.Domain.Entities;

public class CariHesapHareketi
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    // Reference to the Account (Cari Hesap)
    public Guid AccountId { get; set; }
    public Account? Account { get; set; }
    
    // Reference to Customer
    public Guid CustomerId { get; set; }
    
    // Reference to Invoice (if this movement is related to an invoice)
    public Guid? InvoiceId { get; set; }
    public Invoice? Invoice { get; set; }
    
    // Reference to Payment (if this movement is related to a payment)
    public Guid? PaymentId { get; set; }
    public Payment? Payment { get; set; }
    
    // Movement type: Borc (Debit) or Alacak (Credit)
    public HareketTipi HareketTipi { get; set; }
    
    // Amount fields - using decimal for financial precision
    public decimal Borc { get; set; }   // Debit amount
    public decimal Alacak { get; set; }  // Credit amount
    public decimal Bakiye { get; set; }   // Running balance after this entry
    
    // Description of the transaction
    public string Aciklama { get; set; } = string.Empty;
    
    // Reference numbers
    public string? ReferansNumarasi { get; set; }
    public string? BelgeNumarasi { get; set; }  // Document number
    
    // Transaction date
    public DateTimeOffset IslemTarihi { get; set; }
    public DateTimeOffset? VadeTarihi { get; set; }  // Due date
    
    // Audit fields
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public bool IsDeleted { get; set; }
}

public enum HareketTipi
{
    /// <summary>Debit - Borc (money owed by customer)</summary>
    Borc,
    /// <summary>Credit - Alacak (money owed to customer)</summary>
    Alacak,
    /// <summary>Opening balance - Açılış bakiyesi</summary>
    Açılış,
    /// <summary>Closing balance - Kapanış bakiyesi</summary>
    Kapanış
}

/// <summary>
/// Account type enum for accounting module
/// </summary>
public enum AccountingAccountType
{
    /// <summary>Cari/Hesap - Customer account receivable (Alacak/Borc)</summary>
    CariHesap = 1,
    /// <summary>Revenue/Income accounts - tracking company income</summary>
    Gelir = 2,
    /// <summary>Expense accounts - tracking company expenditures</summary>
    Gider = 3,
    /// <summary>Cash accounts - physical cash on hand</summary>
    Kasa = 4,
    /// <summary>Bank accounts - bank accounts and credit lines</summary>
    Banka = 5
}
