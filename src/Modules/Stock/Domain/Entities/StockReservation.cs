using System;

namespace TechSupport.Stock.Domain.Entities;

public enum StockReservationStatus
{
    Reserved,
    Consumed,
    Returned,
    Released
}

public class StockReservation
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid StockItemId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? OperationId { get; set; }
    public Guid? TechnicianUserId { get; set; }
    public long Quantity { get; set; }
    public StockReservationStatus Status { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? ExpiresAtUtc { get; set; }

    // Navigation
    public StockItem? StockItem { get; set; }
}
