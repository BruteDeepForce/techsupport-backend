using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

    public record CreateItemDto(Guid? BranchId, Guid CategoryId, string Sku, string Barcode, string Name, string? Description, string? Unit, long InitialQuantity);

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }

    [Authorize(Roles = "admin, technician")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var item = await _stockService.CreateAsync(tenantId.Value, dto.BranchId, dto.CategoryId, dto.Sku, dto.Barcode, dto.Name, dto.Description, dto.Unit, dto.InitialQuantity, ct);
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
}
