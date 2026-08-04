using TechSupport.Trade.Contracts.Events;

namespace TechSupport.Trade.Domain.Entities;

public enum TradeType
{
    Sale = 1,
    Purchase = 2,
    TradeIn = 3
}

public enum TradePaymentMethod
{
    Cash = 1,
    Card = 2,
    Transfer = 3
}

public enum TradeStatus
{
    Pending = 1,
    Completed = 2,
    Cancelled = 3,
    Failed = 4
}

public sealed class TradeRecord
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? CustomerId { get; set; }
    public Guid? DeviceId { get; set; }
    public Guid? CategoryId { get; set; }
    public TradeType Type { get; set; }
    public TradePaymentMethod PaymentMethod { get; set; }
    public TradeStatus Status { get; set; }
    public DeviceRegisteration? DeviceInfo { get; set; }
    public string? ImeiOrSerial { get; set; }
    public int Quantity { get; set; } = 1;
    public decimal UnitPrice { get; set; }
    public decimal? CostPrice { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal? PaidAmount { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? CompletedAtUtc { get; set; }
    public string IdempotencyKey {get; set;} = string.Empty;
}
