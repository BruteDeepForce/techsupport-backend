using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Stock.DTO;
using TechSupport.Stock.Services;

namespace TechSupport.Stock.Api.Controllers;

[ApiController]
[Route("api/stock/items")]
public class StockItemsController : ControllerBase
{
    private readonly IStockService _stockService;

    public StockItemsController(IStockService stockService)
    {
        _stockService = stockService;
    }


    [Authorize(Roles = "admin, technician")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateItemDTO dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var branchId = GetBranchIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var item = await _stockService.CreateAsync(tenantId.Value,  branchId, dto, ct);
        return Ok(new { item.Id, item.Sku, item.Barcode, item.Name });
    }

    [Authorize(Roles = "admin, technician")]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        return Ok(await _stockService.GetAllAsync(tenantId.Value, ct));
    }
    
    [Authorize(Roles = "admin, technician")]
    [HttpGet("category/{categoryId:guid}")]
    public async Task<IActionResult> GetAllByCategoryId(Guid categoryId, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        return Ok(await _stockService.GetAllByCategoryId(tenantId.Value, categoryId, ct));
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }
    private Guid? GetUserIdFromClaims()
    {
        var userClaim = User.Claims.FirstOrDefault(c => c.Type == "user_id");
        return userClaim != null && Guid.TryParse(userClaim.Value, out var userId) ? userId : null;
    }
     private Guid? GetBranchIdFromClaims()
    {
        var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id");
        return branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId) ? branchId : null;
    }
}
