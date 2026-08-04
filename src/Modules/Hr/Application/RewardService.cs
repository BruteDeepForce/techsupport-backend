using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IRewardService
{
    Task<HRServiceResult<RewardResponse>> CreateAsync(Guid tenantId, CreateRewardRequest request, CancellationToken ct);
    Task<HRServiceResult<RewardResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<RewardResponse>>> ListAsync(Guid tenantId, CancellationToken ct);
    Task<HRServiceResult<RewardResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateRewardRequest request, CancellationToken ct);

    Task<HRServiceResult<RewardEmployeeRecordResponse>> CreateRecordAsync(Guid tenantId, CreateRewardEmployeeRecordRequest request, CancellationToken ct);
    Task<HRServiceResult<RewardEmployeeRecordResponse>> GetRecordByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<RewardEmployeeRecordResponse>>> ListRecordsAsync(
        Guid tenantId,
        Guid? employeeId,
        Guid? rewardId,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct);

    Task<HRServiceResult<RewardEmployeeRecordResponse>> UpdateRecordAsync(Guid tenantId, Guid id, UpdateRewardEmployeeRecordRequest request, CancellationToken ct);
}

public sealed class RewardService : IRewardService
{
    private readonly HRDbContext _db;

    public RewardService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<RewardResponse>> CreateAsync(Guid tenantId, CreateRewardRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<RewardResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            return HRServiceResult<RewardResponse>.Fail("Description is required.");
        }

        if (request.RewardAmount < 0)
        {
            return HRServiceResult<RewardResponse>.Fail("RewardAmount cannot be negative.");
        }

        var now = DateTime.UtcNow;
        var reward = new Reward
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = Guid.Empty,
            Description = request.Description.Trim(),
            RewardAmount = decimal.Round(request.RewardAmount, 2),
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.Rewards.Add(reward);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<RewardResponse>.Ok(ToResponse(reward));
    }

    public async Task<HRServiceResult<RewardResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var reward = await _db.Rewards
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return reward is null
            ? HRServiceResult<RewardResponse>.NotFound("Reward not found.")
            : HRServiceResult<RewardResponse>.Ok(ToResponse(reward));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<RewardResponse>>> ListAsync(Guid tenantId, CancellationToken ct)
    {
        var rewards = await _db.Rewards
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<RewardResponse>>.Ok(rewards.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<RewardResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateRewardRequest request, CancellationToken ct)
    {
        var reward = await _db.Rewards
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (reward is null)
        {
            return HRServiceResult<RewardResponse>.NotFound("Reward not found.");
        }

        if (request.Description is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Description))
            {
                return HRServiceResult<RewardResponse>.Fail("Description cannot be empty.");
            }

            reward.Description = request.Description.Trim();
        }

        if (request.RewardAmount.HasValue)
        {
            if (request.RewardAmount.Value < 0)
            {
                return HRServiceResult<RewardResponse>.Fail("RewardAmount cannot be negative.");
            }

            reward.RewardAmount = decimal.Round(request.RewardAmount.Value, 2);
        }

        reward.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<RewardResponse>.Ok(ToResponse(reward));
    }

    public async Task<HRServiceResult<RewardEmployeeRecordResponse>> CreateRecordAsync(Guid tenantId, CreateRewardEmployeeRecordRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.Fail("TenantId is required.");
        }

        if (request.EmployeeId == Guid.Empty || request.RewardId == Guid.Empty)
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.Fail("EmployeeId and RewardId are required.");
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.Fail("Description is required.");
        }

        var employeeExists = await _db.Employees
            .AsNoTracking()
            .AnyAsync(x =>
                x.Id == request.EmployeeId &&
                x.TenantId == tenantId &&
                x.DeletedAtUtc == null,
                ct);

        if (!employeeExists)
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.NotFound("Employee not found.");
        }

        var rewardExists = await _db.Rewards
            .AsNoTracking()
            .AnyAsync(x =>
                x.Id == request.RewardId &&
                x.TenantId == tenantId,
                ct);

        if (!rewardExists)
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.NotFound("Reward not found.");
        }

        var record = new RewardEmployeeRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = Guid.Empty,
            EmployeeId = request.EmployeeId,
            RewardId = request.RewardId,
            Description = request.Description.Trim(),
            RewardDate = request.RewardDate,
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.RewardEmployeeRecords.Add(record);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<RewardEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    public async Task<HRServiceResult<RewardEmployeeRecordResponse>> GetRecordByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var record = await _db.RewardEmployeeRecords
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return record is null
            ? HRServiceResult<RewardEmployeeRecordResponse>.NotFound("Reward employee record not found.")
            : HRServiceResult<RewardEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<RewardEmployeeRecordResponse>>> ListRecordsAsync(
        Guid tenantId,
        Guid? employeeId,
        Guid? rewardId,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct)
    {
        if (startDate.HasValue && endDate.HasValue && startDate.Value.Date > endDate.Value.Date)
        {
            return HRServiceResult<IReadOnlyCollection<RewardEmployeeRecordResponse>>.Fail("startDate must be earlier than or equal to endDate.");
        }

        var query = _db.RewardEmployeeRecords
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (employeeId.HasValue && employeeId.Value != Guid.Empty)
        {
            query = query.Where(x => x.EmployeeId == employeeId.Value);
        }

        if (rewardId.HasValue && rewardId.Value != Guid.Empty)
        {
            query = query.Where(x => x.RewardId == rewardId.Value);
        }

        if (startDate.HasValue)
        {
            var fromDate = startDate.Value.Date;
            query = query.Where(x => x.RewardDate.Date >= fromDate);
        }

        if (endDate.HasValue)
        {
            var toDate = endDate.Value.Date;
            query = query.Where(x => x.RewardDate.Date <= toDate);
        }

        var records = await query
            .OrderByDescending(x => x.RewardDate)
            .ThenByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<RewardEmployeeRecordResponse>>.Ok(records.Select(ToRecordResponse).ToList());
    }

    public async Task<HRServiceResult<RewardEmployeeRecordResponse>> UpdateRecordAsync(Guid tenantId, Guid id, UpdateRewardEmployeeRecordRequest request, CancellationToken ct)
    {
        var record = await _db.RewardEmployeeRecords
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (record is null)
        {
            return HRServiceResult<RewardEmployeeRecordResponse>.NotFound("Reward employee record not found.");
        }

        if (request.RewardId.HasValue)
        {
            if (request.RewardId.Value == Guid.Empty)
            {
                return HRServiceResult<RewardEmployeeRecordResponse>.Fail("RewardId cannot be empty.");
            }

            var rewardExists = await _db.Rewards
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Id == request.RewardId.Value &&
                    x.TenantId == tenantId &&
                    x.BranchId == record.BranchId,
                    ct);

            if (!rewardExists)
            {
                return HRServiceResult<RewardEmployeeRecordResponse>.NotFound("Reward not found.");
            }

            record.RewardId = request.RewardId.Value;
        }

        if (request.Description is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Description))
            {
                return HRServiceResult<RewardEmployeeRecordResponse>.Fail("Description cannot be empty.");
            }

            record.Description = request.Description.Trim();
        }

        if (request.RewardDate.HasValue)
        {
            record.RewardDate = request.RewardDate.Value;
        }

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<RewardEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    private static RewardResponse ToResponse(Reward reward)
        => new(
            reward.Id,
            reward.TenantId,
            reward.BranchId,
            reward.Description,
            reward.RewardAmount,
            reward.CreatedAtUtc,
            reward.UpdatedAtUtc);

    private static RewardEmployeeRecordResponse ToRecordResponse(RewardEmployeeRecord record)
        => new(
            record.Id,
            record.TenantId,
            record.BranchId,
            record.EmployeeId,
            record.RewardId,
            record.Description,
            record.RewardDate,
            record.CreatedAtUtc);
}
