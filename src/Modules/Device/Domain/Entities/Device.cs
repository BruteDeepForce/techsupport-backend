using MassTransit;

namespace TechSupport.Device.Domain.Entities;

public sealed class Devices
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid? CustomerId { get; set; }
    public DeviceStatus Status { get; set; } = DeviceStatus.Other;
    public string? CustomerName { get; set; }
    public string? ProblemDescription { get; set; } = string.Empty;
    public string Brand { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public string SerialNumber { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public int? GuaranteePeriod { get; set; } // in months
    public DateTimeOffset? WarrantyStartAtUtc { get; set; }
    public DateTimeOffset? WarrantyEndAtUtc { get; set; }
    public string? BarcodeNumber { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? DeactivatedAtUtc { get; set; }
}

public enum DeviceStatus
{
    Other,
    InRepair,
    InMaintenance,
    Selled,
    Returned
}
