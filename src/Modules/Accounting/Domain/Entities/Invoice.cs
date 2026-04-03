using System;
using System.ComponentModel.DataAnnotations;

namespace TechSupport.Accounting.Domain.Entities;

public class Invoice
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid AccountId { get; set; }
    public Account? Account { get; set; }
    
    public Guid CustomerId { get; set; }
    
    public string InvoiceNumber { get; set; } = string.Empty;
    public InvoiceStatus Status { get; set; } = InvoiceStatus.Draft;
    public InvoiceType Type { get; set; } = InvoiceType.Standard;
    
    public DateTimeOffset IssueDate { get; set; }
    public DateTimeOffset DueDate { get; set; }
    public DateTimeOffset? PaidDate { get; set; }
    
    public decimal Subtotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    
    public string? Notes { get; set; }
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public bool IsDeleted { get; set; }
    
    // Concurrency token for optimistic locking
    [Timestamp]
    [ConcurrencyCheck]
    public byte[]? RowVersion { get; set; }
    
    public ICollection<InvoiceLineItem> LineItems { get; set; } = new List<InvoiceLineItem>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

public enum InvoiceStatus
{
    Draft,
    Issued,
    Paid,
    Overdue,
    Cancelled,
    PartiallyPaid,
    PendingPayment
}

public enum InvoiceType
{
    Standard,
    Credit,
    ProForma,
    EInvoice
}
