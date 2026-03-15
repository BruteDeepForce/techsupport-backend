using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

    public sealed record RegisterDeviceDto(Guid TenantId, Guid BranchId, string Brand, string Model, string SerialNumber);

    [Authorize(Roles = "admin,customer")]
    [HttpPost]
    public async Task<IActionResult> Register([FromBody] RegisterDeviceDto dto, CancellationToken ct)
    {
        var device = await _devices.RegisterAsync(dto.TenantId, dto.BranchId, dto.Brand, dto.Model, dto.SerialNumber, ct);
        return Ok(new
        {
            device.Id,
            device.TenantId,
            device.BranchId,
            device.Brand,
            device.Model,
            device.SerialNumber,
            device.IsActive,
            device.CreatedAtUtc
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
