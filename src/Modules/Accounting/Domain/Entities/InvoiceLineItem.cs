using System;

namespace TechSupport.Accounting.Domain.Entities;

public class InvoiceLineItem
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid InvoiceId { get; set; }
    public Invoice? Invoice { get; set; }
    
    public int LineNumber { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ProductCode { get; set; }
    
    public decimal Quantity { get; set; }
    public string Unit { get; set; } = "pcs";
    public decimal UnitPrice { get; set; }
    public decimal TaxRate { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal LineTotal { get; set; }
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public bool IsDeleted { get; set; }
}
