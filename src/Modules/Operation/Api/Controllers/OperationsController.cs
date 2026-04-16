using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Operation.DTO;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.Services;
using System.Security.Claims;
using MassTransit.Internals;

namespace TechSupport.Operation.Api.Controllers;

[ApiController]
[Route("api/operations")]
public sealed class OperationsController : ControllerBase
{
    private readonly IOperationService _ops;

    public OperationsController(IOperationService ops)
    {
        _ops = ops;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateOperationDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var userId = GetUserIdFromClaims();
        var branchId = GetBranchIdFromClaims();
        if (tenantId == null || userId == null) return Unauthorized();
        var op = await _ops.CreateAsync(
            tenantId.Value,
            branchId,
            userId.Value,
            dto.TechnicianInfo?.Name,
            dto.CustomerId,
            dto.DeviceId,
            dto.TechnicianInfo?.TechnicianId,
            dto.Title,
            dto.Description,
            dto.InternalNote,
            null,
            dto.Priority,
            dto.customerName,
            dto.Type ?? OperationType.Repair,
            dto.MaintenanceTemplateId ?? null,
            dto.ScheduledAtUtc,
            ct);
        return Ok(ToResponse(op));
    }

    [Authorize]
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get([FromRoute] Guid id, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var op = await _ops.GetAsync(tenantId.Value, id, ct);
        return op is null ? NotFound() : Ok(ToResponse(op));
    }
    [Authorize]
    [HttpGet("Get-all")]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        var role = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
        if (role == "technician")
        {
            var userId = GetUserIdFromClaims();
            if (userId == null) return Unauthorized();
            var ops = await _ops.TechnicianGetAllAsync(tenantId.Value, userId.Value, ct);
            return Ok(ops.Select(ToResponse));
        }
        else if (role == "customer")
        {
            var userId = GetUserIdFromClaims();
            if (userId == null) return Unauthorized();
            var ops = await _ops.CustomerGetAllAsync(tenantId.Value, userId.Value, ct);
            return Ok(ops.Select(ToResponse));
        }
        else if (role == "admin")
        {
            var ops = await _ops.AdminGetAllAsync(tenantId.Value, ct);
                return Ok(ops.Select(ToResponse));
        }
        return Forbid();
    }

    [Authorize]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update([FromRoute] Guid id, [FromBody] UpdateOperationDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var userId = GetUserIdFromClaims();
        if (tenantId == null || userId == null) return Unauthorized();

        var op = await _ops.UpdateAsync(tenantId.Value, id, userId.Value, dto.Title, dto.Description, dto.ToTechnician, dto.InternalNote, ct);
        return Ok(ToResponse(op));
    }
    //! bu endpoint teknisyen tarafından kullanılmayacak. Sadece operasyonun durumunu güncellemek için ayrı bir endpoint olacak. 
    //! Çünkü operasyonun durumunu güncellemek, operasyonun diğer detaylarını güncellemeye göre daha sık yapılacak bir işlem olabilir ve 
    //! bu işlemi daha hızlı ve basit hale getirmek isteyebiliriz.
    [Authorize]
    [HttpPut("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus([FromRoute] Guid id, [FromBody] UpdateOperationStatusDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var userId = GetUserIdFromClaims();
        if (tenantId == null || userId == null) return Unauthorized();

        var op = await _ops.UpdateStatusAsync(tenantId.Value, id, userId.Value, String.Empty, dto.Status, ct);
        return Ok(ToResponse(op));
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        if (tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId))
        {
            return tenantId;
        }
        return null;
    }
    private Guid? GetUserIdFromClaims()
    {
        var userClaim = User.Claims.FirstOrDefault(c => c.Type == "user_id");
        if (userClaim != null && Guid.TryParse(userClaim.Value, out var userId))
        {
            return userId;
        }
        return null;
    }
    private Guid? GetBranchIdFromClaims()
    {
        var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id");
        if (branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId))
        {
            return branchId;
        }
        return null;
    }

    private static ResponseOperation ToResponse(OperationRecord op)
    {
        return new ResponseOperation(
            op.Id,
            op.TenantId,
            op.BranchId,
            op.CustomerId,
            op.DeviceId,
            op.FieldTechnicianUserId,
            op.Title,
            op.Description,
            op.Status.ToString(),
            op.InternalNote ?? string.Empty,
            op.CustomerFullName ?? string.Empty,
            op.TechnicianFullName ?? string.Empty,
            op.Priority,
            op.CreatedAtUtc,
            op.Type,
            op.MaintenanceTemplateId,
            op.ScheduledAtUtc);
    }
}
