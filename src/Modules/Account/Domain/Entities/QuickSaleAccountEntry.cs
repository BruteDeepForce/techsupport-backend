namespace TechSupport.Account.Domain.Entities;

public enum QuickSaleAccountEntryType
{
    Sale,
    Payment,
    Refund
}

public sealed class QuickSaleAccountEntry
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid QuickSaleId { get; set; }
    public Guid? BranchId { get; set; }
    public string EntryNumber { get; set; } = string.Empty;
    public QuickSaleAccountEntryType EntryType { get; set; } = QuickSaleAccountEntryType.Sale;
    public decimal GrossAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal NetAmount { get; set; }
    public string Currency { get; set; } = "TRY";
    public string PaymentMethod { get; set; } = "Cash";
    public string Description { get; set; } = string.Empty;
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
