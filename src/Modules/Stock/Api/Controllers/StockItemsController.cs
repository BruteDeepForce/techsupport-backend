using Microsoft.EntityFrameworkCore;
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
    private readonly Data.StockDbContext _db;

    public StockItemsController(IStockService stockService, Data.StockDbContext db)
    {
        _stockService = stockService;
        _db = db;
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

    [Authorize(Roles = "admin, technician")]
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var item = await _stockService.GetByIdAsync(tenantId.Value, id, ct);
        if (item == null)
            return NotFound();

        var quantityAvailable = item.Balances.Sum(x => x.QuantityAvailable);
        var quantityReserved = item.Balances.Sum(x => x.QuantityReserved);

        return Ok(new
        {
            item.Id,
            item.TenantId,
            item.BranchId,
            item.DeviceId,
            item.CategoryId,
            item.Sku,
            item.ImeiOrSerial,
            item.Barcode,
            item.Name,
            item.Description,
            item.Unit,
            item.UnitPrice,
            QuantityAvailable = quantityAvailable,
            QuantityReserved = quantityReserved,
            item.CreatedAtUtc,
            item.UpdatedAtUtc
        });
    }

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
