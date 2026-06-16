using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.Application;
using Modules.HR.Domain;
using Modules.HR.DTO;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/leaves")]
[Authorize]
public sealed class LeavesController : ControllerBase
{
    private readonly ILeaveService _service;

    public LeavesController(ILeaveService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateLeaveRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.CreateAsync(tenantId, request, ct);
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

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] Guid? branchId,
        [FromQuery] Guid? employeeId,
        [FromQuery] LeaveStatus? status,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        CancellationToken ct = default)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        // if (branchId == Guid.Empty)
        // {
        //     return BadRequest("BranchId is required.");
        // }

        var result = await _service.ListAsync(tenantId, null, employeeId, status, startDate, endDate, ct);
        if (!result.Succeeded)
        {
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpPost("decision")]
    public async Task<IActionResult> Decide( [FromBody] DecideLeaveRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var claimUserId = TryGetUserId();
        var approverId = claimUserId;
        if(approverId != null)
        {
            request = request with { ApprovedByUserId = approverId };
        }

        if (request.Status is LeaveStatus.Approved or LeaveStatus.Rejected && approverId is null)
        {
            return Unauthorized("UserId is required in claim (user_id).");
        }

        var result = await _service.DecideAsync(tenantId, request.LeaveId, request, ct);

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

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateLeaveRequest request, CancellationToken ct)
    {        if (!TryGetTenantId(out var tenantId))
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

    private bool TryGetTenantId(out Guid tenantId)
    {
        tenantId = Guid.Empty;
        var claimValue = User.FindFirstValue("tenant_id") ?? User.FindFirstValue("tenantId");
        return Guid.TryParse(claimValue, out tenantId);
    }

    private Guid? TryGetUserId()
    {
        var claimValue = User.FindFirstValue("user_id")
            ?? User.FindFirstValue("userId")
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");

        return Guid.TryParse(claimValue, out var userId) ? userId : null;
    }
}
