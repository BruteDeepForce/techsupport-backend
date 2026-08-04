namespace TechSupport.Trade.Domain.Entities;

public enum QuickSaleStatus
{
    Pending,
    StockProcessing,
    AccountingProcessing,
    Completed,
    Failed,
    Compensating,
    Compensated,
    CompensationFailed
}

public enum QuickSalePaymentMethod
{
    Cash,
    Card,
    Transfer
}

public sealed class QuickSale
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid CreatedByUserId { get; set; }
    public string SaleNumber { get; set; } = string.Empty;
    public string IdempotencyKey { get; set; } = string.Empty;
    public QuickSaleStatus Status { get; set; }
    public QuickSalePaymentMethod PaymentMethod { get; set; }
    public decimal Subtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public Guid? AccountingInvoiceId { get; set; }
    public Guid? AccountingPaymentId { get; set; }
    public string? FailureReason { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public DateTimeOffset? CompletedAtUtc { get; set; }
    public DateTimeOffset? FailedAtUtc { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public ICollection<QuickSaleItem> Items { get; set; } = new List<QuickSaleItem>();
}

public sealed class QuickSaleItem
{
    public Guid Id { get; set; }
    public Guid QuickSaleId { get; set; }
    public QuickSale? QuickSale { get; set; }
    public Guid StockItemId { get; set; }
    public string ProductNameSnapshot { get; set; } = string.Empty;
    public string SkuSnapshot { get; set; } = string.Empty;
    public string? BarcodeSnapshot { get; set; }
    public long Quantity { get; set; }
    public decimal UnitPriceSnapshot { get; set; }
    public decimal LineTotal { get; set; }
}
