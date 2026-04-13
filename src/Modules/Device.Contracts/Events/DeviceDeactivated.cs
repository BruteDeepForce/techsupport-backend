namespace TechSupport.Device.Contracts.Events;

/// <summary>
/// Published when a device is deactivated (soft-delete) and should no longer be used.
/// </summary>
public sealed record DeviceDeactivated(
    Guid TenantId,
    Guid BranchId,
    Guid DeviceId,
    DateTimeOffset OccurredAtUtc);
