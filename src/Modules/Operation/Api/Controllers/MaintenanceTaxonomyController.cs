using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Api.Controllers;

[ApiController]
[Route("api/maintenance/taxonomy")]
public sealed class MaintenanceTaxonomyController : ControllerBase
{
    private readonly OperationDbContext _db;

    public MaintenanceTaxonomyController(OperationDbContext db)
    {
        _db = db;
    }

    // --- Product Types ---

    [Authorize]
    [HttpGet("product-types")]
    public async Task<IActionResult> GetProductTypes(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var items = await _db.ProductTypes
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderBy(x => x.Name)
            .Select(x => new TaxonomyItemDto(x.Id, x.Name, x.IsActive))
            .ToListAsync(ct);

        return Ok(items);
    }

    [Authorize(Roles = "admin")]
    [HttpPost("product-types")]
    public async Task<IActionResult> CreateProductType([FromBody] CreateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = new OperationProductType
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId.Value,
            Name = dto.Name.Trim(),
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        _db.ProductTypes.Add(entity);
        await _db.SaveChangesAsync(ct);

        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
    }

    [Authorize(Roles = "admin")]
    [HttpPut("product-types/{id:guid}")]
    public async Task<IActionResult> UpdateProductType([FromRoute] Guid id, [FromBody] UpdateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = await _db.ProductTypes.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);
        if (entity == null) return NotFound();

        entity.Name = dto.Name.Trim();
        entity.IsActive = dto.IsActive;

        await _db.SaveChangesAsync(ct);
        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
    }

    // --- Brands ---

    [Authorize]
    [HttpGet("brands")]
    public async Task<IActionResult> GetBrands(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var items = await _db.Brands
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderBy(x => x.Name)
            .Select(x => new TaxonomyItemDto(x.Id, x.Name, x.IsActive))
            .ToListAsync(ct);

        return Ok(items);
    }

    [Authorize(Roles = "admin")]
    [HttpPost("brands")]
    public async Task<IActionResult> CreateBrand([FromBody] CreateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = new OperationBrand
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId.Value,
            Name = dto.Name.Trim(),
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        _db.Brands.Add(entity);
        await _db.SaveChangesAsync(ct);

        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
    }

    [Authorize(Roles = "admin")]
    [HttpPut("brands/{id:guid}")]
    public async Task<IActionResult> UpdateBrand([FromRoute] Guid id, [FromBody] UpdateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = await _db.Brands.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);
        if (entity == null) return NotFound();

        entity.Name = dto.Name.Trim();
        entity.IsActive = dto.IsActive;

        await _db.SaveChangesAsync(ct);
        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
    }

    // --- Classes ---

    [Authorize]
    [HttpGet("classes")]
    public async Task<IActionResult> GetClasses(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var items = await _db.Classes
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderBy(x => x.Name)
            .Select(x => new TaxonomyItemDto(x.Id, x.Name, x.IsActive))
            .ToListAsync(ct);

        return Ok(items);
    }

    [Authorize(Roles = "admin")]
    [HttpPost("classes")]
    public async Task<IActionResult> CreateClass([FromBody] CreateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = new OperationProductClass
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId.Value,
            Name = dto.Name.Trim(),
            IsActive = true,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        _db.Classes.Add(entity);
        await _db.SaveChangesAsync(ct);

        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
    }

    [Authorize(Roles = "admin")]
    [HttpPut("classes/{id:guid}")]
    public async Task<IActionResult> UpdateClass([FromRoute] Guid id, [FromBody] UpdateTaxonomyItemDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var entity = await _db.Classes.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);
        if (entity == null) return NotFound();

        entity.Name = dto.Name.Trim();
        entity.IsActive = dto.IsActive;

        await _db.SaveChangesAsync(ct);
        return Ok(new TaxonomyItemDto(entity.Id, entity.Name, entity.IsActive));
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
}
