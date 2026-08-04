using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.Application;
using Modules.HR.DTO;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/attendance")]
[Authorize]
public sealed class AttendanceController : ControllerBase
{
    private readonly IAttendanceService _service;

    public AttendanceController(IAttendanceService service)
    {
        _service = service;
    }

    [HttpPost("check-in")]
    public async Task<IActionResult> CheckIn([FromBody] CreateAttendanceCheckInRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized("UserId is required in claim (user_id).");
        }
        request = request with { UserId = userId };

        var result = await _service.CheckInAsync(tenantId, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.NotFound => NotFound(result.Error),
                HRServiceErrorType.Conflict => Conflict(result.Error),
                _ => BadRequest(result.Error)
            };
        }

        return CreatedAtAction(nameof(GetById), new { id = result.Data!.Id }, result.Data);
    }

    [HttpPost("check-out")]
    public async Task<IActionResult> CheckOut([FromBody] CreateAttendanceCheckOutRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized("UserId is required in claim (user_id).");
        }
        request = request with { UserId = userId };
        var result = await _service.CheckOutAsync(tenantId, request, ct);
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

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
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

    [HttpGet("getmy-shifts")]
    public async Task<IActionResult> GetMyShifts(CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized("UserId is required in claim (user_id).");
        }

        var result = await _service.GetMyShiftsAsync(tenantId, userId, ct);
        if (!result.Succeeded)
        {
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("{id:guid}/lateness")]
    public async Task<IActionResult> GetLateness(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetLatenessAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet]
    public async Task<IActionResult> ListByDate([FromQuery] Guid branchId, [FromQuery] DateTime date, CancellationToken ct = default)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        if (branchId == Guid.Empty)
        {
            return BadRequest("BranchId is required.");
        }

        var result = await _service.ListByDateAsync(tenantId, branchId, date, ct);
        if (!result.Succeeded)
        {
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    private bool TryGetTenantId(out Guid tenantId)
    {
        tenantId = Guid.Empty;
        var claimValue = User.FindFirstValue("tenant_id") ?? User.FindFirstValue("tenantId");
        return Guid.TryParse(claimValue, out tenantId);
    }

    private bool TryGetUserId(out Guid userId)
    {
        userId = Guid.Empty;
        var claimValue = User.FindFirstValue("user_id") ?? User.FindFirstValue("userId") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(claimValue, out userId);
    }
}

