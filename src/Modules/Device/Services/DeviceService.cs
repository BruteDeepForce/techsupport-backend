using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using TechSupport.Device.Contracts.Events;
using TechSupport.Device.Data;
using TechSupport.Device.Domain.Entities;

namespace TechSupport.Device.Services;

public interface IDeviceService
{
    Task<Devices> RegisterAsync(Guid tenantId, Guid branchId, string brand, string model, 
    string serialNumber, string? problemDescription, int? guaranteePeriod, DateTimeOffset? warrantyStartAtUtc,
    string? barcodeNumber, Guid? customerId, string? customerName, string status, CancellationToken ct);
    Task<Devices?> GetByIdAsync(Guid tenantId, Guid deviceId, CancellationToken ct);
    Task<Devices> DeactivateAsync(Guid tenantId, Guid deviceId, CancellationToken ct);
    Task<IReadOnlyCollection<Devices>> GetAllAsync(Guid tenantId, CancellationToken ct);
    Task<IReadOnlyCollection<Devices>> GetCustomerDevicesAsync(Guid tenantId, Guid customerId, CancellationToken ct);
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

    public async Task<Devices> RegisterAsync(Guid tenantId, Guid branchId, string brand, 
    string model, string serialNumber, string? problemDescription, int? guaranteePeriod, DateTimeOffset? warrantyStartAtUtc,
    string? barcodeNumber, Guid? customerId, string? customerName, string status, CancellationToken ct)
    {
        var exists = await _db.Devices.AnyAsync(x => x.TenantId == tenantId && x.SerialNumber == serialNumber, ct);
        if (exists) throw new InvalidOperationException("Device already exists for tenant (serialNumber must be unique)");

        var normalizedWarrantyStart = warrantyStartAtUtc?.ToUniversalTime();
        var normalizedWarrantyEnd = normalizedWarrantyStart.HasValue && guaranteePeriod.HasValue
            ? normalizedWarrantyStart.Value.AddMonths(guaranteePeriod.Value)
            : (DateTimeOffset?)null;

    var device = new Devices
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Brand = brand.Trim(),
            Model = model.Trim(),
            SerialNumber = serialNumber.Trim(),
            ProblemDescription = problemDescription?.Trim(),
            GuaranteePeriod = guaranteePeriod,
            WarrantyStartAtUtc = normalizedWarrantyStart,
            WarrantyEndAtUtc = normalizedWarrantyEnd,
            BarcodeNumber = barcodeNumber?.Trim(),
            CustomerId = customerId,
            CustomerName = customerName?.Trim(),
            Status = Enum.TryParse<DeviceStatus>(status, true, out var parsedStatus) ? parsedStatus : DeviceStatus.Other,
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        await _db.Devices.AddAsync(device, ct);
        await _db.SaveChangesAsync(ct);

        if (device.CustomerId.HasValue)
        {
            await _bus.Publish(new DeviceCustomerMapping
            {
                DeviceId = device.Id,
                TenantId = device.TenantId,
                BranchId = device.BranchId,
                CustomerId = device.CustomerId.Value,
                Status = device.Status.ToString(),
                CustomerName = device.CustomerName,
                ProblemDescription = device.ProblemDescription,
                Brand = device.Brand,
                Model = device.Model,
                SerialNumber = device.SerialNumber,
                IsActive = device.IsActive,
                GuaranteePeriod = device.GuaranteePeriod,
                WarrantyStartAtUtc = device.WarrantyStartAtUtc,
                WarrantyEndAtUtc = device.WarrantyEndAtUtc,
                BarcodeNumber = device.BarcodeNumber,
                UpdatedAtUtc = device.UpdatedAtUtc,
                CreatedAtUtc = device.CreatedAtUtc,
                DeactivatedAtUtc = device.DeactivatedAtUtc
            }, ct);
        }
        
        await _bus.Publish(new DeviceCreated(device.TenantId, device.BranchId, device.Id, 
        device.Brand, device.Model, device.SerialNumber, DateTimeOffset.UtcNow), ct);

        return device;
    }

    public Task<Devices?> GetByIdAsync(Guid tenantId, Guid deviceId, CancellationToken ct)
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

    public async Task<IReadOnlyCollection<Devices>> GetAllAsync(Guid tenantId, CancellationToken ct)
    {
        var devices = await _db.Devices.AsNoTracking().Where(x => x.TenantId == tenantId).ToListAsync(ct);
        return devices;
    }

    public async Task<IReadOnlyCollection<Devices>> GetCustomerDevicesAsync(Guid tenantId, Guid customerId, CancellationToken ct)
    {
        var devices = await _db.Devices.AsNoTracking().Where(x => x.TenantId == tenantId && x.CustomerId == customerId).ToListAsync(ct);
        return devices;
    }
}
