using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Api.Controllers;

[ApiController]
[Route("api/maintenance/templates")]
public sealed class MaintenanceTemplatesController : ControllerBase
{
    private readonly OperationDbContext _db;

    public MaintenanceTemplatesController(OperationDbContext db)
    {
        _db = db;
    }

    // Both admin & customer can list/browse templates (customer will typically filter + only active)
    [Authorize]
    [HttpGet]
    public async Task<IActionResult> Query([FromQuery] MaintenanceTemplateQueryDto query, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var q = _db.MaintenanceTemplates
            .AsNoTracking()
            .Include(x => x.Checklists)
            .Where(x => x.TenantId == tenantId);

        // Optional filters
        if (query.IsActive.HasValue)
            q = q.Where(x => x.IsActive == query.IsActive.Value);

        if (query.ProductTypeId.HasValue)
            q = q.Where(x => x.ProductTypeId == query.ProductTypeId);
        if (query.BrandId.HasValue)
            q = q.Where(x => x.BrandId == query.BrandId);
        if (query.ClassId.HasValue)
            q = q.Where(x => x.ClassId == query.ClassId);

        var items = await q
            .OrderBy(x => x.Name)
            .Select(x => new MaintenanceTemplateDto(
                x.Id,
                x.TenantId,
                x.BranchId,
                x.Name,
                x.Description,
                x.IsActive,
                x.ProductTypeId,
                x.ProductTypeName,
                x.BrandId,
                x.BrandName,
                x.ClassId,
                x.ClassName,
                x.Checklists
                    .OrderBy(i => i.SortOrder)
                    .Select(i => new MaintenanceTemplateChecklistDto(i.Id, i.SortOrder, i.Title, i.Description, i.IsRequired, i.IsActive))
                    .ToList(),
                x.CreatedAtUtc))
            .ToListAsync(ct);

        return Ok(items);
    }

    [Authorize]
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get([FromRoute] Guid id, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var t = await _db.MaintenanceTemplates
            .AsNoTracking()
            .Include(x => x.Checklists)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);

        if (t == null) return NotFound();

        return Ok(new MaintenanceTemplateDto(
            t.Id,
            t.TenantId,
            t.BranchId,
            t.Name,
            t.Description,
            t.IsActive,
            t.ProductTypeId,
            t.ProductTypeName,
            t.BrandId,
            t.BrandName,
            t.ClassId,
            t.ClassName,
            t.Checklists.OrderBy(i => i.SortOrder)
                .Select(i => new MaintenanceTemplateChecklistDto(i.Id, i.SortOrder, i.Title, i.Description, i.IsRequired, i.IsActive))
                .ToList(),
            t.CreatedAtUtc));
    }

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateMaintenanceTemplateDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        // Resolve taxonomy names (denormalized snapshot for frontend convenience)
        var productTypeName = dto.ProductTypeId.HasValue
            ? await _db.ProductTypes.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.ProductTypeId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;
        var brandName = dto.BrandId.HasValue
            ? await _db.Brands.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.BrandId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;
        var className = dto.ClassId.HasValue
            ? await _db.Classes.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.ClassId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;

        var template = new MaintenanceTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId.Value,
            BranchId = dto.BranchId,
            Name = dto.Name.Trim(),
            Description = dto.Description?.Trim(),
            IsActive = dto.IsActive,
            ProductTypeId = dto.ProductTypeId,
            ProductTypeName = productTypeName,
            BrandId = dto.BrandId,
            BrandName = brandName,
            ClassId = dto.ClassId,
            ClassName = className,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            Checklists = dto.Checklists?.Select(i => new MaintenanceTemplateChecklist
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId.Value,
                SortOrder = i.SortOrder,
                Title = i.Title.Trim(),
                Description = i.Description?.Trim(),
                IsRequired = i.IsRequired,
                IsActive = i.IsActive,
                CreatedAtUtc = DateTimeOffset.UtcNow
            }).OrderBy(i => i.SortOrder).ToList() ?? new List<MaintenanceTemplateChecklist>()
        };

        await _db.MaintenanceTemplates.AddAsync(template, ct);
        await _db.SaveChangesAsync(ct);

        return Ok(new { template.Id });
    }

    [Authorize(Roles = "admin")]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update([FromRoute] Guid id, [FromBody] UpdateMaintenanceTemplateDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();

        var template = await _db.MaintenanceTemplates
            .Include(x => x.Checklists)
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, ct);

        if (template == null) return NotFound();

        template.BranchId = dto.BranchId;
        template.Name = dto.Name.Trim();
        template.Description = dto.Description?.Trim();
        template.IsActive = dto.IsActive;
        template.ProductTypeId = dto.ProductTypeId;
        template.BrandId = dto.BrandId;
        template.ClassId = dto.ClassId;
        template.UpdatedAtUtc = DateTimeOffset.UtcNow;

        template.ProductTypeName = dto.ProductTypeId.HasValue
            ? await _db.ProductTypes.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.ProductTypeId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;
        template.BrandName = dto.BrandId.HasValue
            ? await _db.Brands.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.BrandId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;
        template.ClassName = dto.ClassId.HasValue
            ? await _db.Classes.AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.Id == dto.ClassId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync(ct)
            : null;

        // Replace items (simple approach for v1)
        _db.MaintenanceTemplateChecklists.RemoveRange(template.Checklists);
        template.Checklists = (dto.Checklists ?? new List<CreateMaintenanceTemplateChecklistDto>())
            .Select(i => new MaintenanceTemplateChecklist
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId.Value,
                MaintenanceTemplateId = template.Id,
                SortOrder = i.SortOrder,
                Title = i.Title.Trim(),
                Description = i.Description?.Trim(),
                IsRequired = i.IsRequired,
                IsActive = i.IsActive,
                CreatedAtUtc = DateTimeOffset.UtcNow
            })
            .OrderBy(i => i.SortOrder)
            .ToList();

        await _db.SaveChangesAsync(ct);

        return Ok(new { template.Id });
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
