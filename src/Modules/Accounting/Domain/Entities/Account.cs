using System;
using System.ComponentModel.DataAnnotations;

namespace TechSupport.Accounting.Domain.Entities;

public class Account
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public string AccountNumber { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    public AccountType Type { get; set; } = AccountType.CariHesap;
    public AccountStatus Status { get; set; } = AccountStatus.Active;
    
    public decimal Balance { get; set; }
    public decimal TotalBorc { get; set; }
    public decimal TotalAlacak { get; set; }
    public decimal CreditLimit { get; set; }  // For bank/credit accounts
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public bool IsDeleted { get; set; }
    
    // Concurrency token for optimistic locking
    [Timestamp]
    [ConcurrencyCheck]
    public byte[]? RowVersion { get; set; }
    
    // Relationships - Invoices generated against this financial account
    public ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

/// <summary>
/// Account types representing different categories of company financial accounts
/// </summary>
public enum AccountType
{
    /// <summary>Cari/Hesap - Customer account receivable (Alacak/Borc)</summary>
    CariHesap,
    /// <summary>Revenue/Income accounts - tracking company income</summary>
    Gelir,
    /// <summary>Expense accounts - tracking company expenditures</summary>
    Gider,
    /// <summary>Cash accounts - physical cash on hand</summary>
    Kasa,
    /// <summary>Bank accounts - bank accounts and credit lines</summary>
    Banka
}

public enum AccountStatus
{
    Active,
    Suspended,
    Closed
}
