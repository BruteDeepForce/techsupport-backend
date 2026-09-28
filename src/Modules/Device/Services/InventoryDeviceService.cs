using Microsoft.EntityFrameworkCore;
using TechSupport.Device.Data;
using TechSupport.Device.Domain.Entities;
using TechSupport.Stock.Contracts.Services;

namespace TechSupport.Device.Services;

public interface IInventoryDeviceService
{
    Task<InventoryDeviceResult> CreateAsync(Guid tenantId, Guid branchId, CreateInventoryDeviceRequest request, CancellationToken ct);
}

public sealed record CreateInventoryDeviceRequest(
    string Brand,
    string Model,
    string SerialNumber,
    Guid CategoryId,
    string Sku,
    string BarcodeNumber,
    decimal CurrentSalePrice,
    DeviceProductCondition ProductCondition,
    int? GuaranteePeriod,
    DateTimeOffset? WarrantyStartAtUtc,
    string? ProblemDescription,
    string? Description,
    string? Unit,
    long Quantity = 1);

public sealed record InventoryDeviceResult(
    Guid DeviceId,
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid StockItemId,
    string Brand,
    string Model,
    string SerialNumber,
    string BarcodeNumber,
    decimal CurrentSalePrice,
    DeviceStatus Status,
    DeviceProductCondition ProductCondition,
    bool IsActive,
    int? GuaranteePeriod,
    DateTimeOffset? WarrantyStartAtUtc,
    DateTimeOffset? WarrantyEndAtUtc,
    long Quantity);

public sealed class InventoryDeviceService : IInventoryDeviceService
{
    private readonly DeviceDbContext _deviceDb;
    private readonly IInventoryStockItemWriter _stockItemWriter;

    public InventoryDeviceService(DeviceDbContext deviceDb, IInventoryStockItemWriter stockItemWriter)
    {
        _deviceDb = deviceDb;
        _stockItemWriter = stockItemWriter;
    }

    public async Task<InventoryDeviceResult> CreateAsync(Guid tenantId, Guid branchId, CreateInventoryDeviceRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty) throw new ArgumentException("TenantId is required.", nameof(tenantId));
        if (branchId == Guid.Empty) throw new ArgumentException("BranchId is required.", nameof(branchId));
        if (request.CategoryId == Guid.Empty) throw new InvalidOperationException("CategoryId is required.");
        if (request.Quantity <= 0) throw new InvalidOperationException("Quantity must be greater than zero.");
        if (request.CurrentSalePrice <= 0) throw new InvalidOperationException("CurrentSalePrice must be greater than zero.");

        var brand = RequiredTrim(request.Brand, nameof(request.Brand));
        var model = RequiredTrim(request.Model, nameof(request.Model));
        var serialNumber = RequiredTrim(request.SerialNumber, nameof(request.SerialNumber));
        var sku = RequiredTrim(request.Sku, nameof(request.Sku));
        var barcodeNumber = RequiredTrim(request.BarcodeNumber, nameof(request.BarcodeNumber));

        var exists = await _deviceDb.Devices.AnyAsync(x => x.TenantId == tenantId && x.SerialNumber == serialNumber, ct);
        if (exists) throw new InvalidOperationException("Device already exists for tenant (serialNumber must be unique)");

        var normalizedWarrantyStart = request.WarrantyStartAtUtc?.ToUniversalTime();
        var normalizedWarrantyEnd = normalizedWarrantyStart.HasValue && request.GuaranteePeriod.HasValue
            ? normalizedWarrantyStart.Value.AddMonths(request.GuaranteePeriod.Value)
            : (DateTimeOffset?)null;

        var device = new Devices
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Brand = brand,
            Model = model,
            SerialNumber = serialNumber,
            BarcodeNumber = barcodeNumber,
            CurrentSalePrice = request.CurrentSalePrice,
            ProductCondition = request.ProductCondition,
            ProblemDescription = request.ProblemDescription?.Trim(),
            GuaranteePeriod = request.GuaranteePeriod,
            WarrantyStartAtUtc = normalizedWarrantyStart,
            WarrantyEndAtUtc = normalizedWarrantyEnd,
            Status = DeviceStatus.Saleable,
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        await _deviceDb.Devices.AddAsync(device, ct);
        await _deviceDb.SaveChangesAsync(ct);

        try
        {
            var stockItem = await _stockItemWriter.CreateForDeviceAsync(
                new InventoryStockItemCreateRequest(
                    tenantId,
                    branchId,
                    device.Id,
                    request.CategoryId,
                    sku,
                    serialNumber,
                    barcodeNumber,
                    $"{brand} {model}".Trim(),
                    request.Description?.Trim() ?? request.ProblemDescription?.Trim(),
                    string.IsNullOrWhiteSpace(request.Unit) ? "Adet" : request.Unit.Trim(),
                    request.CurrentSalePrice,
                    request.Quantity),
                ct);

            return new InventoryDeviceResult(
                device.Id,
                device.Id,
                device.TenantId,
                device.BranchId,
                stockItem.StockItemId,
                device.Brand,
                device.Model,
                device.SerialNumber,
                barcodeNumber,
                device.CurrentSalePrice.Value,
                device.Status,
                device.ProductCondition,
                device.IsActive,
                device.GuaranteePeriod,
                device.WarrantyStartAtUtc,
                device.WarrantyEndAtUtc,
                request.Quantity);
        }
        catch
        {
            _deviceDb.Devices.Remove(device);
            await _deviceDb.SaveChangesAsync(ct);
            throw;
        }
    }

    private static string RequiredTrim(string value, string name)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException($"{name} is required.");

        return value.Trim();
    }
}
