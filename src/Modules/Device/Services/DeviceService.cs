using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Device.Contracts.Events;
using TechSupport.Device.Data;
using TechSupport.Device.Domain.Entities;

namespace TechSupport.Device.Services;

public interface IDeviceService
{
    Task<Devices> RegisterAsync(Guid tenantId, Guid branchId, string brand, string model, string serialNumber, CancellationToken ct);
    Task<Devices?> GetAsync(Guid tenantId, Guid deviceId, CancellationToken ct);
    Task<Devices> DeactivateAsync(Guid tenantId, Guid deviceId, CancellationToken ct);
}

public sealed class DeviceService : IDeviceService
{
    private readonly DeviceDbContext _db;
    private readonly IBus _bus;

    public DeviceService(DeviceDbContext db, IBus bus)
    {
        _db = db;
        _bus = bus;
    }

    public async Task<Devices> RegisterAsync(Guid tenantId, Guid branchId, string brand, string model, string serialNumber, CancellationToken ct)
    {
        var exists = await _db.Devices.AnyAsync(x => x.TenantId == tenantId && x.SerialNumber == serialNumber, ct);
        if (exists) throw new InvalidOperationException("Device already exists for tenant (serialNumber must be unique)");

    var device = new Devices
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Brand = brand.Trim(),
            Model = model.Trim(),
            SerialNumber = serialNumber.Trim(),
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        _db.Devices.Add(device);
        await _db.SaveChangesAsync(ct);

        await _bus.Publish(new DeviceCreated(device.TenantId, device.BranchId, device.Id, device.Brand, device.Model, device.SerialNumber, DateTimeOffset.UtcNow), ct);

        return device;
    }

    public Task<Devices?> GetAsync(Guid tenantId, Guid deviceId, CancellationToken ct)
    {
        return _db.Devices.AsNoTracking().FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == deviceId, ct);
    }

    public async Task<Devices> DeactivateAsync(Guid tenantId, Guid deviceId, CancellationToken ct)
    {
        var device = await _db.Devices.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == deviceId, ct);
        if (device is null) throw new KeyNotFoundException("Device not found");

        if (!device.IsActive) return device;

        device.IsActive = false;
        device.DeactivatedAtUtc = DateTimeOffset.UtcNow;
        await _db.SaveChangesAsync(ct);

        await _bus.Publish(new DeviceDeactivated(device.TenantId, device.BranchId, device.Id, DateTimeOffset.UtcNow), ct);

        return device;
    }
}
