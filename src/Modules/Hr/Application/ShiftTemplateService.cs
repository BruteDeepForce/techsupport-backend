using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IShiftTemplateService
{
    Task<HRServiceResult<ShiftTemplateResponse>> CreateAsync(Guid tenantId, CreateShiftTemplateRequest request, CancellationToken ct);
    Task<HRServiceResult<ShiftTemplateResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<ShiftTemplateResponse>>> ListAsync(Guid tenantId, Guid branchId, bool includeInactive, CancellationToken ct);
    Task<HRServiceResult<ShiftTemplateResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateShiftTemplateRequest request, CancellationToken ct);
}

public sealed class ShiftTemplateService : IShiftTemplateService
{
    private readonly HRDbContext _db;

    public ShiftTemplateService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<ShiftTemplateResponse>> CreateAsync(Guid tenantId, CreateShiftTemplateRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<ShiftTemplateResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return HRServiceResult<ShiftTemplateResponse>.Fail("Name is required.");
        }

        if (!IsValidTimeRange(request.StartTime, request.EndTime, request.IsNightShift ?? false))
        {
            return HRServiceResult<ShiftTemplateResponse>.Fail("Shift time range is invalid.");
        }

        var trimmedName = request.Name.Trim();
        var exists = await _db.ShiftTemplates
            .AnyAsync(x => x.TenantId == tenantId && x.BranchId == request.BranchId && x.Name == trimmedName, ct);

        if (exists)
        {
            return HRServiceResult<ShiftTemplateResponse>.Conflict("Shift template name already exists.");
        }

        var now = DateTime.UtcNow;
        var template = new ShiftTemplate
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            Name = trimmedName,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            IsNightShift = request.IsNightShift ?? false,
            IsActive = request.IsActive ?? true,
            Description = request.Description?.Trim(),
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.ShiftTemplates.Add(template);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<ShiftTemplateResponse>.Ok(ToResponse(template));
    }

    public async Task<HRServiceResult<ShiftTemplateResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var template = await _db.ShiftTemplates
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return template is null
            ? HRServiceResult<ShiftTemplateResponse>.NotFound("Shift template not found.")
            : HRServiceResult<ShiftTemplateResponse>.Ok(ToResponse(template));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<ShiftTemplateResponse>>> ListAsync(Guid tenantId, Guid branchId, bool includeInactive, CancellationToken ct)
    {
        var query = _db.ShiftTemplates
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId != Guid.Empty)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!includeInactive)
        {
            query = query.Where(x => x.IsActive);
        }

        var templates = await query
            .OrderBy(x => x.Name)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<ShiftTemplateResponse>>.Ok(templates.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<ShiftTemplateResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateShiftTemplateRequest request, CancellationToken ct)
    {
        var template = await _db.ShiftTemplates
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (template is null)
        {
            return HRServiceResult<ShiftTemplateResponse>.NotFound("Shift template not found.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmedName = request.Name.Trim();
            if (!string.Equals(template.Name, trimmedName, StringComparison.OrdinalIgnoreCase))
            {
                var exists = await _db.ShiftTemplates
                    .AnyAsync(x => x.TenantId == tenantId && x.BranchId == template.BranchId && x.Name == trimmedName && x.Id != id, ct);

                if (exists)
                {
                    return HRServiceResult<ShiftTemplateResponse>.Conflict("Shift template name already exists.");
                }
            }

            template.Name = trimmedName;
        }

        if (request.StartTime.HasValue)
        {
            template.StartTime = request.StartTime.Value;
        }

        if (request.EndTime.HasValue)
        {
            template.EndTime = request.EndTime.Value;
        }

        if (!IsValidTimeRange(template.StartTime, template.EndTime, template.IsNightShift))
        {
            return HRServiceResult<ShiftTemplateResponse>.Fail("Shift time range is invalid.");
        }

        if (request.IsNightShift.HasValue)
        {
            template.IsNightShift = request.IsNightShift.Value;
        }

        if (request.IsActive.HasValue)
        {
            template.IsActive = request.IsActive.Value;
        }

        template.Description = request.Description?.Trim();
        template.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<ShiftTemplateResponse>.Ok(ToResponse(template));
    }

    private static ShiftTemplateResponse ToResponse(ShiftTemplate template)
        => new(
            template.Id,
            template.TenantId,
            template.BranchId,
            template.Name,
            template.StartTime,
            template.EndTime,
            template.IsNightShift,
            template.IsActive,
            template.Description,
            template.CreatedAtUtc,
            template.UpdatedAtUtc);

    private static bool IsValidTimeRange(TimeSpan startTime, TimeSpan endTime, bool isNightShift)
    {
        if (startTime == endTime)
        {
            return false;
        }

        if (isNightShift)
        {
            return true;
        }

        return startTime < endTime;
    }
}
