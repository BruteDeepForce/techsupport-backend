using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.Application;
using Modules.HR.DTO;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/bordro")]
[Authorize]
public sealed class BordroController : ControllerBase
{
    private readonly IBordroService _service;

    public BordroController(IBordroService service)
    {
        _service = service;
    }

    [HttpPost("donemler")]
    public async Task<IActionResult> CreateDonem([FromBody] CreateBordroDonemRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.CreateDonemAsync(tenantId, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType switch
            {
                HRServiceErrorType.Conflict => Conflict(result.Error),
                _ => BadRequest(result.Error)
            };
        }

        return CreatedAtAction(nameof(GetDonemById), new { id = result.Data!.Id }, result.Data);
    }

    [HttpGet("donemler/{id:guid}")]
    public async Task<IActionResult> GetDonemById(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetDonemByIdAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("donemler")]
    public async Task<IActionResult> ListDonemler([FromQuery] Guid branchId, [FromQuery] bool includeClosed = false, CancellationToken ct = default)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.ListDonemAsync(tenantId, branchId, includeClosed, ct);
        if (!result.Succeeded)
        {
            return BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpPost("donemler/{id:guid}/calculate")]
    public async Task<IActionResult> CalculateDonem(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.CalculateDonemAsync(tenantId, id, ct);
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

    [HttpGet("donemler/{id:guid}/employees")]
    public async Task<IActionResult> ListDonemEmployees(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.ListDonemEmployeesAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpPatch("donemler/{id:guid}/status")]
    public async Task<IActionResult> UpdateDonemStatus(Guid id, [FromBody] UpdateBordroDonemStatusRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.UpdateDonemStatusAsync(tenantId, id, request, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("employees/{id:guid}")]
    public async Task<IActionResult> GetBordroEmployeeDetail(Guid id, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetBordroEmployeeDetailAsync(tenantId, id, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data);
    }

    [HttpGet("employees/{bordroEmployeeId:guid}/generatePdf")]
    public async Task<IActionResult> GenerateBordroEmployeePdf(Guid bordroEmployeeId, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GenerateBordroEmployeePdfAsync(tenantId, bordroEmployeeId, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        var pdfBytes = result.Data!;
        return File(pdfBytes, "application/pdf", $"Bordro_{bordroEmployeeId}.pdf");
    }
    [HttpPost("kalemler")]
    public async Task<IActionResult> AddKalem([FromBody] CreateBordroKalemRequest request, CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.AddKalemAsync(tenantId, request, ct);
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
}
