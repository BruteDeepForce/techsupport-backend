using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface ILeaveSettingsService
{
    Task<HRServiceResult<LeaveDeductionResponse>> CreateAsync(Guid tenantId, CreateLeaveDeductionRequest request, CancellationToken ct);
    Task<HRServiceResult<LeaveDeductionResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<LeaveDeductionResponse>>> ListAsync(Guid tenantId, CancellationToken ct);
    Task<HRServiceResult<LeaveDeductionResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateLeaveDeductionRequest request, CancellationToken ct);
    Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct);
}

public sealed class LeaveSettingsService : ILeaveSettingsService
{
    private readonly HRDbContext _db;

    public LeaveSettingsService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<LeaveDeductionResponse>> CreateAsync(Guid tenantId, CreateLeaveDeductionRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("Description is required.");
        }

        if (!request.DeductionType.HasValue)
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("DeductionType is required.");
        }

        if (!request.DeductionPeriod.HasValue)
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("DeductionPeriod is required.");
        }

        if (request.DeductionAmount < 0)
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("DeductionAmount cannot be negative.");
        }

        var exists = await _db.LeaveDeductions
            .AnyAsync(x =>
                x.TenantId == tenantId &&
                x.DeductionType == request.DeductionType,
                ct);

        if (exists)
        {
            return HRServiceResult<LeaveDeductionResponse>.Conflict("Leave deduction setting already exists for this leave type.");
        }

        var now = DateTime.UtcNow;
        var setting = new LeaveDeduction
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = Guid.Empty,
            Description = request.Description.Trim(),
            DeductionType = request.DeductionType,
            DeductionPeriod = request.DeductionPeriod,
            DeductionAmount = decimal.Round(request.DeductionAmount, 2),
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.LeaveDeductions.Add(setting);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<LeaveDeductionResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<LeaveDeductionResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var setting = await _db.LeaveDeductions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return setting is null
            ? HRServiceResult<LeaveDeductionResponse>.NotFound("Leave deduction setting not found.")
            : HRServiceResult<LeaveDeductionResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<LeaveDeductionResponse>>> ListAsync(Guid tenantId, CancellationToken ct)
    {
        var query = _db.LeaveDeductions
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        var settings = await query
            .OrderBy(x => x.DeductionType)
            .ThenBy(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<LeaveDeductionResponse>>.Ok(settings.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<LeaveDeductionResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateLeaveDeductionRequest request, CancellationToken ct)
    {
        var setting = await _db.LeaveDeductions
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (setting is null)
        {
            return HRServiceResult<LeaveDeductionResponse>.NotFound("Leave deduction setting not found.");
        }

        if (request.DeductionAmount.HasValue && request.DeductionAmount.Value < 0)
        {
            return HRServiceResult<LeaveDeductionResponse>.Fail("DeductionAmount cannot be negative.");
        }

        if (request.DeductionType.HasValue && request.DeductionType != setting.DeductionType)
        {
            var exists = await _db.LeaveDeductions
                .AnyAsync(x =>
                    x.TenantId == tenantId &&
                    x.DeductionType == request.DeductionType &&
                    x.Id != id,
                    ct);

            if (exists)
            {
                return HRServiceResult<LeaveDeductionResponse>.Conflict("Leave deduction setting already exists for this leave type.");
            }

            setting.DeductionType = request.DeductionType;
        }

        if (request.Description is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Description))
            {
                return HRServiceResult<LeaveDeductionResponse>.Fail("Description cannot be empty.");
            }

            setting.Description = request.Description.Trim();
        }

        if (request.DeductionPeriod.HasValue)
        {
            setting.DeductionPeriod = request.DeductionPeriod;
        }

        if (request.DeductionAmount.HasValue)
        {
            setting.DeductionAmount = decimal.Round(request.DeductionAmount.Value, 2);
        }

        setting.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<LeaveDeductionResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var setting = await _db.LeaveDeductions
            .Include(x => x.Leaves)
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (setting is null)
        {
            return HRServiceResult<bool>.NotFound("Leave deduction setting not found.");
        }

        if (setting.Leaves.Any())
        {
            return HRServiceResult<bool>.Conflict("Leave deduction setting is used by leave records and cannot be deleted.");
        }

        _db.LeaveDeductions.Remove(setting);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<bool>.Ok(true);
    }

    private static LeaveDeductionResponse ToResponse(LeaveDeduction setting)
        => new(
            setting.Id,
            setting.TenantId,
            setting.BranchId,
            setting.Description,
            setting.DeductionType,
            setting.DeductionPeriod,
            setting.DeductionAmount,
            setting.CreatedAtUtc,
            setting.UpdatedAtUtc);
}
