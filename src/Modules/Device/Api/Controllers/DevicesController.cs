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

    public sealed record RegisterDeviceDto(
    string Brand, string Model, string SerialNumber,
    string? ProblemDescription, int? GuaranteePeriod, DateTimeOffset? WarrantyStartAtUtc,
    string? BarcodeNumber, Guid? CustomerId, Guid? appUserId, string? CustomerName,
    string Status);

    [Authorize(Roles = "admin,customer")]
    [HttpPost]
    public async Task<IActionResult> Register([FromBody] RegisterDeviceDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var branchId = GetBranchIdFromClaims();
        var device = await _devices.RegisterAsync(tenantId.Value, branchId.Value, dto.Brand, dto.Model, dto.SerialNumber,
            dto.ProblemDescription, dto.GuaranteePeriod, dto.WarrantyStartAtUtc, dto.BarcodeNumber, dto.CustomerId, dto.appUserId, dto.CustomerName, dto.Status, ct);
        return Ok(new
        {
            device.Id,
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
    public async Task<IActionResult> Get([FromRoute] Guid deviceId,  CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var device = await _devices.GetByIdAsync(tenantId.Value, deviceId, ct);
        return device is null ? NotFound() : Ok(device);
    }

    [Authorize(Roles = "admin")]
    [HttpPost("{deviceId:guid}/deactivate")]
    public async Task<IActionResult> Deactivate([FromRoute] Guid deviceId,  CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var device = await _devices.DeactivateAsync(tenantId.Value, deviceId, ct);
        return Ok(new { device.Id, device.IsActive, device.DeactivatedAtUtc });
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {        
        var tenantId = GetTenantIdFromClaims();
        var devices = await _devices.GetAllAsync(tenantId.Value, ct);
        return Ok(devices);
    }   

    [Authorize]
    [HttpGet("customer/{customerId:guid}")]
    public async Task<IActionResult> GetCustomerDevices([FromRoute] Guid customerId,  CancellationToken ct)
    {        
        var tenantId = GetTenantIdFromClaims();
        var devices = await _devices.GetCustomerDevicesAsync(tenantId.Value, customerId, ct);
        return Ok(devices);
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantIdClaim = User.Claims.FirstOrDefault(c => c.Type == "tenantId") 
            ?? User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantIdClaim != null ? Guid.Parse(tenantIdClaim.Value) : null;
    }
    
     private Guid? GetBranchIdFromClaims()
    {
        var branchIdClaim = User.Claims.FirstOrDefault(c => c.Type == "branchId") 
            ?? User.Claims.FirstOrDefault(c => c.Type == "branch_id");
        return branchIdClaim != null ? Guid.Parse(branchIdClaim.Value) : null;
    }

     private Guid? GetUserIdFromClaims()
    {
        var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "userId") 
            ?? User.Claims.FirstOrDefault(c => c.Type == "user_id");
        return userIdClaim != null ? Guid.Parse(userIdClaim.Value) : null;
    }
}
