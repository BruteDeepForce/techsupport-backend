using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.Api.Controllers;

[ApiController]
[Route("api/technicians")]
public class TechnicianController : ControllerBase
{
    private readonly ITechnicianService _technicians;

    public TechnicianController(ITechnicianService technicians)
    {
        _technicians = technicians;
    }

    public sealed record CreateTechnicianDto(string FirstName, string LastName, string Email, string? PhoneNumber, string TemporaryPassword);
    public sealed record SetActiveDto(bool IsActive);
    public sealed record UpdateWorkItemStatusDto(string Status);

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTechnicianDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var branchId = GetBranchIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var request = await _technicians.StartProvisioningAsync(tenantId.Value, branchId, dto.FirstName, dto.Email, dto.PhoneNumber, dto.TemporaryPassword, ct);
        return Accepted(new
        {
            correlationId = request.CorrelationId,
            status = request.Status.ToString()
        });
    }

    [Authorize(Roles = "admin")]
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        return Ok(await _technicians.ListAsync(tenantId.Value, ct));
    }

    [Authorize]
    [HttpGet("{technicianId:guid}")]
    public async Task<IActionResult> Get(Guid technicianId, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var technician = await _technicians.GetByIdAsync(tenantId.Value, technicianId, ct);
        return technician is null ? NotFound() : Ok(technician);
    }

    [Authorize(Roles = "admin")]
    [HttpGet("provisioning/{correlationId:guid}")]
    public async Task<IActionResult> GetProvisioningStatus(Guid correlationId, CancellationToken ct)
    {
        var status = await _technicians.GetProvisioningStatusAsync(correlationId, ct);
        if (status is null) return NotFound();

        return Ok(new
        {
            status.CorrelationId,
            Status = status.Status.ToString(),
            status.TechnicianId,
            status.AppUserId,
            status.FailureReason,
            status.CreatedAtUtc,
            status.CompletedAtUtc
        });
    }

    [Authorize(Roles = "admin")]
    [HttpPatch("{technicianId:guid}/active")]
    public async Task<IActionResult> SetActive(Guid technicianId, [FromBody] SetActiveDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var updated = await _technicians.SetActiveAsync(tenantId.Value, technicianId, dto.IsActive, ct);
        return updated ? NoContent() : NotFound();
    }

    [Authorize(Roles = "technician")]
    [HttpPatch("operations/{operationId:guid}/status")]
    public async Task<IActionResult> UpdateWorkItemStatus(Guid operationId, [FromBody] UpdateWorkItemStatusDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        // We keep userId as technician identity; Operation module will validate/translate as needed.
        var techClaim = User.Claims.FirstOrDefault(c => c.Type == "sub" || c.Type == "user_id" || c.Type.EndsWith("nameidentifier", StringComparison.OrdinalIgnoreCase));
        if (techClaim is null || !Guid.TryParse(techClaim.Value, out var technicianUserId))
            return Unauthorized();
        var technicianInfo = User.Claims.FirstOrDefault(c=> c.Type == "username" || c.Type == "name")?.Value ?? "Unknown Technician";
        var op = await _technicians.UpdateOperationStatusAsync(tenantId.Value, operationId, technicianUserId, technicianInfo, dto.Status, ct);
        return Ok(new { op.OperationId, Status = op.Status.ToString() });
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }

    private Guid? GetBranchIdFromClaims()
    {
        var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id");
        return branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId) ? branchId : null;
    }
}
