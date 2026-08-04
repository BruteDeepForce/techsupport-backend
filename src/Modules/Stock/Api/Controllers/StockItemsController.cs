using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Stock.Services;

namespace TechSupport.Stock.Api.Controllers;

[ApiController]
[Route("api/stock/items")]
public class StockItemsController : ControllerBase
{
    private readonly IStockService _stockService;
    private readonly Data.StockDbContext _db;

    public StockItemsController(IStockService stockService, Data.StockDbContext db)
    {
        _stockService = stockService;
        _db = db;
    }

    public record CreateItemDto(Guid? BranchId, Guid? CategoryId, string Sku, string Barcode, string Name, string? Description, string? Unit, long InitialQuantity);

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var items = await _db.StockItems
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId.Value)
            .Select(x => new
            {
                x.Id,
                x.Sku,
                x.Barcode,
                x.Name,
                x.Description,
                balances = x.Balances.Select(b => new
                {
                    b.Id,
                    b.BranchId,
                    quantityAvailable = b.QuantityAvailable,
                    quantityReserved = b.QuantityReserved
                })
            })
            .ToListAsync(ct);

        return Ok(items);
    }

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var item = await _stockService.CreateAsync(tenantId.Value, dto.BranchId, dto.Sku, dto.Barcode, dto.Name, dto.Description, dto.Unit, dto.InitialQuantity, ct);
        return Ok(new { item.Id, item.Sku, item.Barcode, item.Name });
    }
}
