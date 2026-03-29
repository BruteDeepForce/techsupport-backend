using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Device.Domain.Entities;
using TechSupport.Device.Services;

namespace TechSupport.Device.Api.Controllers;

[ApiController]
[Route("api/devices")]
public sealed class DevicesController : ControllerBase
{
    private readonly IDeviceService _devices;

    public DevicesController(IDeviceService devices)
    {
        _devices = devices;
    }

    public sealed record RegisterDeviceDto(Guid TenantId, Guid BranchId, 
    string Brand, string Model, string SerialNumber,
    string? ProblemDescription, int? GuaranteePeriod, DateTimeOffset? WarrantyStartAtUtc,
    string? BarcodeNumber, Guid? CustomerId, string? CustomerName,
    string Status);

    [Authorize(Roles = "admin,customer")]
    [HttpPost]
    public async Task<IActionResult> Register([FromBody] RegisterDeviceDto dto, CancellationToken ct)
    {
        var device = await _devices.RegisterAsync(dto.TenantId, dto.BranchId, dto.Brand, dto.Model, dto.SerialNumber,
            dto.ProblemDescription, dto.GuaranteePeriod, dto.WarrantyStartAtUtc, dto.BarcodeNumber, dto.CustomerId, dto.CustomerName, dto.Status, ct);
        return Ok(new
        {
            device.Id,
            device.TenantId,
            device.BranchId,
            device.Brand,
            device.Model,
            device.SerialNumber,
            device.IsActive,
            device.CreatedAtUtc,
            device.UpdatedAtUtc,
            device.ProblemDescription,
            device.GuaranteePeriod,
            device.WarrantyStartAtUtc,
            device.WarrantyEndAtUtc,
            device.BarcodeNumber,
            device.CustomerId,
            device.CustomerName,
            device.Status
        });
    }

    [Authorize]
    [HttpGet("{deviceId:guid}")]
    public async Task<IActionResult> Get([FromRoute] Guid deviceId, [FromQuery] Guid tenantId, CancellationToken ct)
    {
        var device = await _devices.GetAsync(tenantId, deviceId, ct);
        return device is null ? NotFound() : Ok(device);
    }

    [Authorize(Roles = "admin")]
    [HttpPost("{deviceId:guid}/deactivate")]
    public async Task<IActionResult> Deactivate([FromRoute] Guid deviceId, [FromQuery] Guid tenantId, CancellationToken ct)
    {
        var device = await _devices.DeactivateAsync(tenantId, deviceId, ct);
        return Ok(new { device.Id, device.IsActive, device.DeactivatedAtUtc });
    }
}
