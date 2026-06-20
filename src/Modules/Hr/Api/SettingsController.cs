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
    private readonly ILeaveSettingsService _leaveSettingsService;
    private readonly IAdvanceService _advanceService;

    public SettingsController(ILeaveSettingsService leaveSettingsService, IAdvanceService advanceService)
    {
        _leaveSettingsService = leaveSettingsService;
        _advanceService = advanceService;
    }

    [HttpPost("leave-deductions")]
    public async Task<IActionResult> CreateLeaveDeductionSetting([FromBody] CreateLeaveDeductionRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _leaveSettingsService.CreateAsync(tenantId, request, ct);
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

        var result = await _leaveSettingsService.GetByIdAsync(tenantId, id, ct);
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

        var result = await _leaveSettingsService.ListAsync(tenantId, ct);
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

        var result = await _leaveSettingsService.UpdateAsync(tenantId, id, request, ct);
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

        var result = await _leaveSettingsService.DeleteAsync(tenantId, id, ct);
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

    [HttpPost("advance-settings")]
    public async Task<IActionResult> CreateAdvanceSettings([FromBody] CreateAdvanceSettingsRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _advanceService.CreateAdvanceSettingsAsync(tenantId, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.Conflict
                ? Conflict(result.Error)
                : BadRequest(result.Error);
        }

        return CreatedAtAction(nameof(GetAdvanceSettingsById), new { id = result.Data!.Id }, result.Data);
    }

    [HttpPatch("advance-settings/{id:guid}")]
    public async Task<IActionResult> UpdateAdvanceSettings(Guid id, [FromBody] UpdateAdvanceSettingsRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _advanceService.UpdateAdvanceSettingsAsync(tenantId, id, request, ct);
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

    [HttpGet("advance-settings/{id:guid}")]
    public async Task<IActionResult> GetAdvanceSettingsById(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _advanceService.GetAdvanceSettingsByIdAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("advance-settings/current")]
    public async Task<IActionResult> GetCurrentAdvanceSettings(CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _advanceService.GetCurrentAdvanceSettingsAsync(tenantId, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    private bool TryGetTenantId(out Guid tenantId)
    {
        tenantId = Guid.Empty;
        var claimValue = User.FindFirstValue("tenant_id") ?? User.FindFirstValue("tenantId");
        return Guid.TryParse(claimValue, out tenantId);
    }
}
