using System;

namespace TechSupport.Stock.Domain.Entities;

public enum StockReservationStatus
{
    Pending,
    Approved,
    Finalized,
    Released,
    Rejected
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
    public decimal? UnitPriceSnapshot { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? RequestedAtUtc { get; set; }
    public DateTime? ApprovedAtUtc { get; set; }
    public DateTime? FinalizedAtUtc { get; set; }
    public DateTime? ReleasedAtUtc { get; set; }
    public DateTime? RejectedAtUtc { get; set; }
    public string? RejectedReason { get; set; }
    public DateTime? ExpiresAtUtc { get; set; }

    // Navigation
    public StockItem? StockItem { get; set; }
}
