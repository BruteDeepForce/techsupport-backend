using System;
using System.ComponentModel.DataAnnotations;

namespace TechSupport.Stock.Domain.Entities;

public class StockBalance
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid StockItemId { get; set; }
    public Guid? BranchId { get; set; }
    public long QuantityAvailable { get; set; }
    public long QuantityReserved { get; set; }

    // optimistic concurrency
    [Timestamp]
    public byte[]? RowVersion { get; set; }

    // Navigation
    public StockItem? StockItem { get; set; }
}
