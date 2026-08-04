using System;

namespace TechSupport.Stock.Domain.Entities;

public enum StockTransactionType
{
    Init,
    Take,
    Consume,
    Return,
    Adjust,
    Reserve
}

public class StockTransaction
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid StockItemId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? OperationId { get; set; }
    public Guid? UserId { get; set; }
    public long Quantity { get; set; }
    public StockTransactionType Type { get; set; }
    public string? Reference { get; set; }
    public string? Barcode { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    // Navigation
    public StockItem? StockItem { get; set; }
}
