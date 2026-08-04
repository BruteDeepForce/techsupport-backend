using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Data;

namespace TechSupport.Stock.Api.Controllers;

[ApiController]
[Authorize(Roles = "admin")]
[Route("api/trade/quick-sales/products")]
public sealed class QuickSaleProductsController(StockDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? search = null, [FromQuery] Guid? categoryId = null,
        [FromQuery] int page = 1, [FromQuery] int pageSize = 50, CancellationToken ct = default)
    {
        var tenantId = ClaimGuid("tenant_id");
        var branchId = ClaimGuid("branch_id");
        if (!tenantId.HasValue || !branchId.HasValue) return Unauthorized();

        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 100);
        var query = dbContext.StockItems.AsNoTracking()
            .Where(item => item.TenantId == tenantId && item.UnitPrice != null && item.UnitPrice >= 0)
            .Select(item => new
            {
                item.Id, item.Name, item.Sku, item.Barcode, item.CategoryId, item.UnitPrice,
                QuantityAvailable = item.Balances
                    .Where(balance => balance.BranchId == branchId)
                    .Sum(balance => balance.QuantityAvailable)
            })
            .Where(item => item.QuantityAvailable > 0);

        if (categoryId.HasValue) query = query.Where(x => x.CategoryId == categoryId);
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x => EF.Functions.ILike(x.Name, $"%{term}%") ||
                                     EF.Functions.ILike(x.Sku, $"%{term}%") ||
                                     (x.Barcode != null && EF.Functions.ILike(x.Barcode, $"%{term}%")));
        }

        var totalCount = await query.CountAsync(ct);
        var items = await query.OrderBy(x => x.Name).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
        return Ok(new { page, pageSize, totalCount, items });
    }

    private Guid? ClaimGuid(string type)
    {
        var value = User.Claims.FirstOrDefault(x => x.Type == type)?.Value;
        return Guid.TryParse(value, out var parsed) ? parsed : null;
    }
}
