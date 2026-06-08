using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.Application;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/reports/mini")]
[Authorize]
public sealed class MiniReportsController : ControllerBase
{
    private readonly IMiniReportService _service;

    public MiniReportsController(IMiniReportService service)
    {
        _service = service;
    }

    [HttpGet("department/{departmentId:guid}")]
    public async Task<IActionResult> ByDepartment(
        Guid departmentId,
        [FromQuery] Guid? branchId,
        [FromQuery] int page = 1,
        [FromQuery] int limit = 20,
        CancellationToken ct = default)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.LeaveAndAdvancesByDepartmentID(departmentId, tenantId, branchId, page, limit, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.NotFound => NotFound(result.Error),
                _ => BadRequest(result.Error)
            };
        }

        return Ok(result.Data);
    }

    [HttpGet("employee/{userId:guid}")]
    public async Task<IActionResult> ByEmployeeUser(
        Guid userId,
        [FromQuery] Guid? branchId,
        [FromQuery] int page = 1,
        [FromQuery] int limit = 20,
        CancellationToken ct = default)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.LeaveAndAdvancesByEmployeeUserID(tenantId, branchId, userId, page, limit, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.NotFound => NotFound(result.Error),
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
}
