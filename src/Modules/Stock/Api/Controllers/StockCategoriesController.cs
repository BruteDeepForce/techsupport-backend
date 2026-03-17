using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Stock.Services;

namespace TechSupport.Stock.Api.Controllers;

[ApiController]
[Route("api/stock/categories")]
public class StockCategoriesController : ControllerBase
{
    private readonly ICategoryService _categories;

    public StockCategoriesController(ICategoryService categories)
    {
        _categories = categories;
    }

    public record CreateCategoryDto(Guid? BranchId, string Name);

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCategoryDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        var cat = await _categories.CreateAsync(tenantId.Value, dto.BranchId, dto.Name, ct);
        return Ok(new { cat.Id, cat.Name });
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        var list = await _categories.GetAllAsync(tenantId.Value, ct);
        return Ok(list.Select(x => new { x.Id, x.Name }));
    }
}
