using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Operation.Services;
using TechSupport.Operation.DTO;
using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.Api.Controllers;

[ApiController]
[Route("api/operations/tickets")]
public sealed class TicketsController : ControllerBase
{
    private readonly ITicketService _tickets;

    public TicketsController(ITicketService tickets)
    {
        _tickets = tickets;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTicketDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var userId = GetUserIdFromClaims();
        var branchId = GetBranchIdFromClaims();
    if (tenantId == null || userId == null) return Unauthorized();

    // CustomerId is taken from authenticated user claims (userId)
    var ticket = await _tickets.CreateAsync(tenantId.Value, branchId, userId.Value, dto.DeviceId, dto.Title, dto.Description, dto.Priority ?? Priority.Normal, ct);
        return Ok(ToResponse(ticket));
    }

    [Authorize]
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get([FromRoute] Guid id, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var ticket = await _tickets.GetAsync(tenantId.Value, id, ct);
        return ticket is null ? NotFound() : Ok(ToResponse(ticket));
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value;
        if (role == "customer")
        {
            var userId = GetUserIdFromClaims();
            if (userId == null) return Unauthorized();
            var list = await _tickets.CustomerGetAllAsync(tenantId.Value, userId.Value, ct);
            return Ok(list.Select(ToResponse));
        }
        else if (role == "admin")
        {
            var list = await _tickets.AdminGetAllAsync(tenantId.Value, ct);
            return Ok(list.Select(ToResponse));
        }
        return Forbid();
    }

    [Authorize]
    [HttpPost("{id:guid}/convert")]
    public async Task<IActionResult> Convert([FromRoute] Guid id, [FromBody] ConvertTicketDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var userId = GetUserIdFromClaims();
        if (tenantId == null || userId == null) return Unauthorized();
        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value;
        if (role != "admin") return Forbid();

        var op = await _tickets.ConvertAsync(tenantId.Value, id, userId.Value, dto.ToTechnician, dto.InternalNote, dto.priority, ct);
        return Ok(new { operationId = op.Id });
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

    private static ResponseTicket ToResponse(Ticket t)
    {
        return new ResponseTicket(t.Id, t.TenantId, t.BranchId, t.CustomerId, t.DeviceId, t.Title, t.Description, t.Priority.ToString(), t.Status.ToString(), t.CreatedAtUtc, t.OperationId);
    }
}
