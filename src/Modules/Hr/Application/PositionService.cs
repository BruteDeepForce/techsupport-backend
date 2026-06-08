using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IPositionService
{
    Task<HRServiceResult<PositionResponse>> CreateAsync(Guid tenantId, CreatePositionRequest request, CancellationToken ct);
    Task<HRServiceResult<PositionResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<PositionResponse>>> ListAsync(Guid tenantId, bool includeInactive, CancellationToken ct);
    Task<HRServiceResult<PositionResponse>> UpdateAsync(Guid tenantId, Guid id, UpdatePositionRequest request, CancellationToken ct);
}

public sealed class PositionService : IPositionService
{
    private readonly HRDbContext _db;

    public PositionService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<PositionResponse>> CreateAsync(Guid tenantId, CreatePositionRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<PositionResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return HRServiceResult<PositionResponse>.Fail("Name is required.");
        }

        var trimmedName = request.Name.Trim();
        var exists = await _db.Positions
            .AnyAsync(x => x.TenantId == tenantId && x.Name == trimmedName, ct);

        if (exists)
        {
            return HRServiceResult<PositionResponse>.Conflict("Position name already exists.");
        }

        var now = DateTime.UtcNow;
        var position = new Position
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = trimmedName,
            Description = request.Description?.Trim(),
            IsActive = request.IsActive ?? true,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.Positions.Add(position);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<PositionResponse>.Ok(ToResponse(position));
    }

    public async Task<HRServiceResult<PositionResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var position = await _db.Positions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return position is null
            ? HRServiceResult<PositionResponse>.NotFound("Position not found.")
            : HRServiceResult<PositionResponse>.Ok(ToResponse(position));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<PositionResponse>>> ListAsync(Guid tenantId, bool includeInactive, CancellationToken ct)
    {
        var query = _db.Positions
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (!includeInactive)
        {
            query = query.Where(x => x.IsActive);
        }

        var positions = await query
            .OrderBy(x => x.Name)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<PositionResponse>>.Ok(positions.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<PositionResponse>> UpdateAsync(Guid tenantId, Guid id, UpdatePositionRequest request, CancellationToken ct)
    {
        var position = await _db.Positions
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (position is null)
        {
            return HRServiceResult<PositionResponse>.NotFound("Position not found.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmedName = request.Name.Trim();
            if (!string.Equals(position.Name, trimmedName, StringComparison.OrdinalIgnoreCase))
            {
                var exists = await _db.Positions
                    .AnyAsync(x => x.TenantId == tenantId && x.Name == trimmedName && x.Id != id, ct);

                if (exists)
                {
                    return HRServiceResult<PositionResponse>.Conflict("Position name already exists.");
                }
            }

            position.Name = trimmedName;
        }

        position.Description = request.Description?.Trim();
        if (request.IsActive.HasValue)
        {
            position.IsActive = request.IsActive.Value;
        }

        position.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<PositionResponse>.Ok(ToResponse(position));
    }

    private static PositionResponse ToResponse(Position position)
        => new(
            position.Id,
            position.TenantId,
            position.Name,
            position.Description,
            position.IsActive,
            position.CreatedAtUtc,
            position.UpdatedAtUtc);
}
