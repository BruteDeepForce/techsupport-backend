using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.Application;
using Modules.HR.DTO;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/settings")]
[Authorize]
public sealed class SettingsController : ControllerBase
{
    private readonly ILeaveSettingsService _service;

    public SettingsController(ILeaveSettingsService service)
    {
        _service = service;
    }

    [HttpPost("leave-deductions")]
    public async Task<IActionResult> CreateLeaveDeductionSetting([FromBody] CreateLeaveDeductionRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.CreateAsync(tenantId, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.Conflict
                ? Conflict(result.Error)
                : BadRequest(result.Error);
        }

        return CreatedAtAction(nameof(GetLeaveDeductionSettingById), new { id = result.Data!.Id }, result.Data);
    }

    [HttpGet("leave-deductions/{id:guid}")]
    public async Task<IActionResult> GetLeaveDeductionSettingById(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetByIdAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("leave-deductions")]
    public async Task<IActionResult> ListLeaveDeductionSettings(CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.ListAsync(tenantId, ct);
        if (!result.Succeeded)
        {
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpPut("leave-deductions/{id:guid}")]
    public async Task<IActionResult> UpdateLeaveDeductionSetting(Guid id, [FromBody] UpdateLeaveDeductionRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.UpdateAsync(tenantId, id, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.NotFound => NotFound(result.Error),
                HRServiceErrorType.Conflict => Conflict(result.Error),
                _ => BadRequest(result.Error)
            };
        }

        return Ok(result.Data);
    }

    [HttpDelete("leave-deductions/{id:guid}")]
    public async Task<IActionResult> DeleteLeaveDeductionSetting(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.DeleteAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.NotFound => NotFound(result.Error),
                HRServiceErrorType.Conflict => Conflict(result.Error),
                _ => BadRequest(result.Error)
            };
        }

        return NoContent();
    }

    private bool TryGetTenantId(out Guid tenantId)
    {
        tenantId = Guid.Empty;
        var claimValue = User.FindFirstValue("tenant_id") ?? User.FindFirstValue("tenantId");
        return Guid.TryParse(claimValue, out tenantId);
    }
}
