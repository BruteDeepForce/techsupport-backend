namespace TechSupport.Device.Contracts.Events;

/// <summary>
/// Published by Device bounded-context when a new device is registered.
/// </summary>
public sealed record DeviceCreated(
    Guid TenantId,
    Guid BranchId,
    Guid DeviceId,
    string Brand,
    string Model,
    string SerialNumber,
    DateTimeOffset OccurredAtUtc);
