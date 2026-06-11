using System.ComponentModel.DataAnnotations;
using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.DTO;

public sealed class StartTradeRequest
{
    // New orchestrator inputs: either existing ids or payloads for creation.
    public Guid? ExistingCustomerId { get; set; }
    public string? ExistingCustomerName { get; set; } = string.Empty;
    public Guid? ExistingCusomerAppUserId { get; set; }
    public Guid? ExistingDeviceId { get; set; }

    public Guid? CategoryId { get; set; } // //! satın alımlar için 
    public StartTradeCustomerPayload? Customer { get; set; }
    public StartTradeDevicePayload? Device { get; set; }
    public TradeType Type { get; set; }
    public TradePaymentMethod PaymentMethod { get; set; }
    public int Quantity { get; set; } = 1;
    public decimal UnitPrice { get; set; }
    public decimal? CostPrice { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal? PaidAmount { get; set; }
    public string? ImeiOrSerial { get; set; }
    public string? Notes { get; set; }
}
public sealed class StartTradeCustomerPayload
{
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [MaxLength(320)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(32)]
    public string? PhoneNumber { get; set; }

    [Required]
    [MaxLength(256)]
    public string TemporaryPassword { get; set; } = string.Empty;
}

public sealed class StartTradeDevicePayload
{
    [Required]
    [MaxLength(128)]
    public string Brand { get; set; } = string.Empty;

    [Required]
    [MaxLength(128)]
    public string Model { get; set; } = string.Empty;

    [Required]
    [MaxLength(128)]
    public string SerialNumber { get; set; } = string.Empty;

    public string SKU { get; set; } = string.Empty;

    [MaxLength(4000)]
    public string? ProblemDescription { get; set; }

    [Range(0, int.MaxValue)]
    public int? GuaranteePeriod { get; set; }

    public DateTimeOffset? WarrantyStartAtUtc { get; set; }

    [MaxLength(128)]
    public string? BarcodeNumber { get; set; }

    [MaxLength(200)]
    public string? CustomerName { get; set; }

    [Required]
    [MaxLength(64)]
    public string Status { get; set; } = "Other";
}

