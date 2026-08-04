namespace TechSupport.Trade.Domain.Entities;

public enum QuickSaleStatus
{
    Draft,
    Completed,
    Cancelled
}

public sealed class QuickSale
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public string SaleNumber { get; set; } = string.Empty;
    public QuickSaleStatus Status { get; set; } = QuickSaleStatus.Completed;
    public decimal SubtotalAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public string Currency { get; set; } = "TRY";
    public string PaymentMethod { get; set; } = "Cash";
    public string? Note { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public ICollection<QuickSaleLine> Lines { get; set; } = new List<QuickSaleLine>();
}

public sealed class QuickSaleLine
{
    public Guid Id { get; set; }
    public Guid QuickSaleId { get; set; }
    public QuickSale? QuickSale { get; set; }
    public Guid StockItemId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
    public decimal LineTotal { get; set; }
}
