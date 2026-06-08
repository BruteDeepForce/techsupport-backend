using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Trade.DTO;
using TechSupport.Trade.Services;

namespace TechSupport.Trade.Api.Controllers;

[ApiController]
[Route("api/{controller}")]
public sealed class TradesController : ControllerBase
{
    private readonly ITradeService _tradeService;

    public TradesController(ITradeService tradeService)
    {
        _tradeService = tradeService;
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id")
            ?? User.Claims.FirstOrDefault(c => c.Type == "tenantId");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }
    private Guid? GetBranchIdFromClaims()
    {
        var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id")
            ?? User.Claims.FirstOrDefault(c => c.Type == "branchId");
        return branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId) ? branchId : null;
    }

    [Authorize]
    [HttpPost("start")]
    public async Task<IActionResult> Start([FromBody] StartTradeRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null)
            return Unauthorized(new { error = "Tenant claim not found" });
        var branchId =  Guid.NewGuid();// Allow branchId to be optional, use Guid.Empty if not provided
        //if (branchId is null)
       //     return BadRequest(new { error = "Branch claim not found" });


        var idempotencySource = request.ImeiOrSerial
            ?? request.Device?.SerialNumber;

        if (string.IsNullOrWhiteSpace(idempotencySource))
            return BadRequest(new { error = "ImeiOrSerial or Device.SerialNumber is required for idempotency key generation." });

        var normalizedSource = idempotencySource.Trim().ToUpperInvariant();
        string idempotencyKey = $"key-trade-start-{tenantId.Value:N}-{branchId:N}-{normalizedSource}";
        idempotencyKey = idempotencyKey.Trim().ToLowerInvariant();
        

        try
        {
            var created = await _tradeService.StartTradeAsync(tenantId.Value, branchId, request, idempotencyKey, cancellationToken);
            
            return Ok(new { tradeId = created.Id, idempotencyKey = created.IdempotencyKey });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [Authorize]
    [HttpGet("{tradeId:guid}")]
    public async Task<IActionResult> GetById(Guid tradeId, CancellationToken cancellationToken)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null)
            return Unauthorized(new { error = "Tenant claim not found" });

        var trade = await _tradeService.GetByIdAsync(tenantId.Value, tradeId, cancellationToken);
        if (trade is null)
            return NotFound(new { error = "Trade not found" });

        return Ok(trade);
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetTrades(int page = 1, int pageSize = 10, CancellationToken cancellationToken = default)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null)
            return Unauthorized(new { error = "Tenant claim not found" });

        var result = await _tradeService.GetTradesAsync(tenantId.Value, page, pageSize, cancellationToken);
        if (!result.Success)
            return NotFound(new { error = result.ErrorMessage });

        return Ok(result.Data);
    }
}
