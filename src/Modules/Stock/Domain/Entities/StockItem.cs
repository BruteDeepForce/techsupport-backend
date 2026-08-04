using System;

namespace TechSupport.Stock.Domain.Entities;

public class StockItem
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? DeviceId { get; set; } //! unique 
    public Guid? CategoryId { get; set; }
    public StockCategories? Category { get; set; }
    
    public string Sku { get; set; } = string.Empty; //! unique  
    public string? ImeiOrSerial { get; set; } //! unique 
    public string? Barcode { get; set; } = string.Empty; //! unique 
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal? UnitPrice { get; set; }
    public string? Unit { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; set; }

    // Navigation properties
    public ICollection<StockBalance> Balances { get; set; } = new List<StockBalance>();
    public ICollection<StockTransaction> Transactions { get; set; } = new List<StockTransaction>();
    public ICollection<StockReservation> Reservations { get; set; } = new List<StockReservation>();
}
