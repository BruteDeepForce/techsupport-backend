using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IDepartmentService
{
    Task<HRServiceResult<DepartmentResponse>> CreateAsync(Guid tenantId, CreateDepartmentRequest request, CancellationToken ct);
    Task<HRServiceResult<DepartmentResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<DepartmentResponse>>> ListAsync(Guid tenantId, bool includeInactive, CancellationToken ct);
    Task<HRServiceResult<DepartmentResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateDepartmentRequest request, CancellationToken ct);
}

public sealed class DepartmentService : IDepartmentService
{
    private readonly HRDbContext _db;

    public DepartmentService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<DepartmentResponse>> CreateAsync(Guid tenantId, CreateDepartmentRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<DepartmentResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return HRServiceResult<DepartmentResponse>.Fail("Name is required.");
        }

        var trimmedName = request.Name.Trim();
        var exists = await _db.Departments
            .AnyAsync(x => x.TenantId == tenantId && x.Name == trimmedName, ct);

        if (exists)
        {
            return HRServiceResult<DepartmentResponse>.Conflict("Department name already exists.");
        }

        var now = DateTime.UtcNow;
        var department = new Department
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = trimmedName,
            Code = request.Code?.Trim(),
            Description = request.Description?.Trim(),
            IsActive = request.IsActive ?? true,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.Departments.Add(department);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DepartmentResponse>.Ok(ToResponse(department));
    }

    public async Task<HRServiceResult<DepartmentResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var department = await _db.Departments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return department is null
            ? HRServiceResult<DepartmentResponse>.NotFound("Department not found.")
            : HRServiceResult<DepartmentResponse>.Ok(ToResponse(department));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<DepartmentResponse>>> ListAsync(Guid tenantId, bool includeInactive, CancellationToken ct)
    {
        var query = _db.Departments
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (!includeInactive)
        {
            query = query.Where(x => x.IsActive);
        }

        var departments = await query
            .OrderBy(x => x.Name)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<DepartmentResponse>>.Ok(departments.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<DepartmentResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateDepartmentRequest request, CancellationToken ct)
    {
        var department = await _db.Departments
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (department is null)
        {
            return HRServiceResult<DepartmentResponse>.NotFound("Department not found.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmedName = request.Name.Trim();
            if (!string.Equals(department.Name, trimmedName, StringComparison.OrdinalIgnoreCase))
            {
                var exists = await _db.Departments
                    .AnyAsync(x => x.TenantId == tenantId && x.Name == trimmedName && x.Id != id, ct);

                if (exists)
                {
                    return HRServiceResult<DepartmentResponse>.Conflict("Department name already exists.");
                }
            }

            department.Name = trimmedName;
        }

        department.Code = request.Code?.Trim();
        department.Description = request.Description?.Trim();
        if (request.IsActive.HasValue)
        {
            department.IsActive = request.IsActive.Value;
        }

        department.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DepartmentResponse>.Ok(ToResponse(department));
    }

    private static DepartmentResponse ToResponse(Department department)
        => new(
            department.Id,
            department.TenantId,
            department.Name,
            department.Code,
            department.Description,
            department.IsActive,
            department.CreatedAtUtc,
            department.UpdatedAtUtc);
}
