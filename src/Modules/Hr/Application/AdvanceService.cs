using System.Data.Common;
using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IAdvanceService
{
    Task<HRServiceResult<AdvanceResponse>> CreateAsync(Guid tenantId, CreateAdvanceRequest request, CancellationToken ct);
    Task<HRServiceResult<AdvanceResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<AdvanceResponse>>> ListAsync(
        Guid tenantId,
        Guid branchId,
        Guid? employeeId,
        AdvanceStatus? status,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct);
    Task<HRServiceResult<AdvanceResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateAdvanceRequest request, CancellationToken ct);
    Task<HRServiceResult<AdvanceResponse>> DecideAsync(Guid tenantId, Guid id, DecideAdvanceRequest request, CancellationToken ct);
    Task<HRServiceResult<AdvanceSettingsResponse>> CreateAdvanceSettingsAsync(Guid tenantId, CreateAdvanceSettingsRequest request, CancellationToken ct);
    Task<HRServiceResult<AdvanceSettingsResponse>> UpdateAdvanceSettingsAsync(Guid tenantId, Guid id, UpdateAdvanceSettingsRequest request, CancellationToken ct);
    Task<HRServiceResult<AdvanceSettingsResponse>> GetAdvanceSettingsByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<AdvanceSettingsResponse>> GetCurrentAdvanceSettingsAsync(Guid tenantId, CancellationToken ct);
}

public sealed class AdvanceService : IAdvanceService
{
    private readonly HRDbContext _db;

    public AdvanceService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<AdvanceResponse>> CreateAsync(Guid tenantId, CreateAdvanceRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<AdvanceResponse>.Fail("TenantId is required.");
        }

        if (request.EmployeeId == Guid.Empty)
        {
            return HRServiceResult<AdvanceResponse>.Fail("EmployeeId is required.");
        }

        if (request.Amount <= 0)
        {
            return HRServiceResult<AdvanceResponse>.Fail("Amount must be greater than zero.");
        }

        if (string.IsNullOrWhiteSpace(request.Reason))
        {
            return HRServiceResult<AdvanceResponse>.Fail("Reason is required.");
        }

        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.EmployeeId &&
                x.TenantId == tenantId &&
                (x.BranchId == request.BranchId || request.BranchId == Guid.Empty) &&
                x.DeletedAtUtc == null,
                ct);

        if (employee is null)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Employee not found.");
        }

        var advanceSettings = await _db.AdvanceSettings
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                (x.BranchId == request.BranchId || request.BranchId == Guid.Empty) &&
                x.IsActive,
                ct);
                
        if (advanceSettings is null)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Avans ayarları bulunamadı. Lütfen ayarları kontrol ediniz.");
        }

        if (!advanceSettings.AllowFutureAdvances && request.isFutureAdvance)
        {
            return HRServiceResult<AdvanceResponse>.Fail("Taksitli avanslar için izin verilmemektedir.");
        }
        //! taksitli nakit avans sistemi

        else if (advanceSettings.AllowFutureAdvances && request.isFutureAdvance)
        {
            var taksit = request.Amount / request.TaksitSayisi;

            if (taksit <= 0)
            {
                return HRServiceResult<AdvanceResponse>.Fail("Taksitli avanslarda taksit miktarı sıfırdan büyük olmalıdır.");
            }

            for(int i = 0; i < request.TaksitSayisi; i++)
            {
                var taksitAmount = decimal.Round(taksit, 2);
                var taksitAdvance = new Advance
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantId,
                    BranchId = request.BranchId,
                    DepartmentId = request.DepartmentId,
                    EmployeeId = request.EmployeeId,
                    Amount = taksitAmount,
                    Reason = $"{request.Reason.Trim()} - Taksit {i + 1}/{request.TaksitSayisi}",
                    Status = AdvanceStatus.Pending,
                    CreatedAtUtc = DateTime.UtcNow.AddMonths(i),
                    UpdatedAtUtc = DateTime.UtcNow
                };
                _db.Advances.Add(taksitAdvance);
            }          
        }

        var currentYear = DateTime.UtcNow.Year;
        var advanceCountThisYear = await _db.Advances
            .AsNoTracking()
            .CountAsync(x =>
                x.TenantId == tenantId &&
                x.EmployeeId == request.EmployeeId &&
                x.CreatedAtUtc.Year == currentYear,
                ct);

        if (advanceCountThisYear >= advanceSettings.MaxAdvanceCountPerYear)
        {
            return HRServiceResult<AdvanceResponse>.Fail($"Bu yıl için izin verilen maksimum avans sayısına ulaşıldı. (Yıllık Maksimum Avans Miktarı: {advanceSettings.MaxAdvanceCountPerYear})");
        }
        if (request.Amount > advanceSettings.MaxAdvanceAmountPerPerson)
        {
            return HRServiceResult<AdvanceResponse>.Fail($"Avans miktarı, kişi başına izin verilen maksimum avans miktarını aşmaktadır. (Maksimum Avans Miktarı: {advanceSettings.MaxAdvanceAmountPerPerson})");
        }

        //var departmentExists = await _db.Departments
        //    .AsNoTracking()
        //    .AnyAsync(x => x.Id == request.DepartmentId && x.TenantId == tenantId, ct);

        //if (!departmentExists)
        //{
        //    return HRServiceResult<AdvanceResponse>.NotFound("Department not found.");
        //}


        // if (employee.DepartmentId.HasValue && employee.DepartmentId.Value != request.DepartmentId)
        //{
        //    return HRServiceResult<AdvanceResponse>.Fail("DepartmentId does not match employee department.");
        //}

        var now = DateTime.UtcNow;
        var advance = new Advance
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            DepartmentId = request.DepartmentId,
            EmployeeId = request.EmployeeId,
            Amount = decimal.Round(request.Amount, 2),
            Reason = request.Reason.Trim(),
            Status = AdvanceStatus.Pending,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };


        _db.Advances.Add(advance);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AdvanceResponse>.Ok(ToResponse(advance));
    }

    public async Task<HRServiceResult<AdvanceResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var advance = await _db.Advances
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return advance is null
            ? HRServiceResult<AdvanceResponse>.NotFound("Advance request not found.")
            : HRServiceResult<AdvanceResponse>.Ok(ToResponse(advance));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<AdvanceResponse>>> ListAsync(
        Guid tenantId,
        Guid branchId,
        Guid? employeeId,
        AdvanceStatus? status,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct)
    {
        if (branchId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<AdvanceResponse>>.Fail("BranchId is required.");
        }

        if (startDate.HasValue && endDate.HasValue && startDate.Value.Date > endDate.Value.Date)
        {
            return HRServiceResult<IReadOnlyCollection<AdvanceResponse>>.Fail("startDate must be earlier than or equal to endDate.");
        }

        var query = _db.Advances
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId);

        if (employeeId.HasValue && employeeId.Value != Guid.Empty)
        {
            query = query.Where(x => x.EmployeeId == employeeId.Value);
        }

        if (status.HasValue)
        {
            query = query.Where(x => x.Status == status.Value);
        }

        if (startDate.HasValue)
        {
            var fromDate = startDate.Value.Date;
            query = query.Where(x => x.CreatedAtUtc.Date >= fromDate);
        }

        if (endDate.HasValue)
        {
            var toDate = endDate.Value.Date;
            query = query.Where(x => x.CreatedAtUtc.Date <= toDate);
        }

        var advances = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<AdvanceResponse>>.Ok(advances.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<AdvanceResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateAdvanceRequest request, CancellationToken ct)
    {
        var advance = await _db.Advances
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (advance is null)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Advance request not found.");
        }

        if (advance.Status != AdvanceStatus.Pending)
        {
            return HRServiceResult<AdvanceResponse>.Conflict("Only pending advance requests can be updated.");
        }

        if (request.Amount.HasValue && request.Amount.Value <= 0)
        {
            return HRServiceResult<AdvanceResponse>.Fail("Amount must be greater than zero.");
        }

        if (request.Reason is not null && string.IsNullOrWhiteSpace(request.Reason))
        {
            return HRServiceResult<AdvanceResponse>.Fail("Reason cannot be empty.");
        }

        if (request.DepartmentId.HasValue && request.DepartmentId.Value != advance.DepartmentId)
        {
            var departmentExists = await _db.Departments
                .AsNoTracking()
                .AnyAsync(x => x.Id == request.DepartmentId.Value && x.TenantId == tenantId, ct);

            if (!departmentExists)
            {
                return HRServiceResult<AdvanceResponse>.NotFound("Department not found.");
            }

            var employee = await _db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == advance.EmployeeId && x.TenantId == tenantId && x.DeletedAtUtc == null, ct);

            if (employee is null)
            {
                return HRServiceResult<AdvanceResponse>.NotFound("Employee not found.");
            }

            if (employee.DepartmentId.HasValue && employee.DepartmentId.Value != request.DepartmentId.Value)
            {
                return HRServiceResult<AdvanceResponse>.Fail("DepartmentId does not match employee department.");
            }

            advance.DepartmentId = request.DepartmentId.Value;
        }

        if (request.Amount.HasValue)
        {
            advance.Amount = decimal.Round(request.Amount.Value, 2);
        }

        if (request.Reason is not null)
        {
            advance.Reason = request.Reason.Trim();
        }

        advance.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AdvanceResponse>.Ok(ToResponse(advance));
    }

    public async Task<HRServiceResult<AdvanceResponse>> DecideAsync(Guid tenantId, Guid id, DecideAdvanceRequest request, CancellationToken ct)
    {
        if (!Enum.IsDefined(typeof(AdvanceStatus), request.Status))
        {
            return HRServiceResult<AdvanceResponse>.Fail("Invalid advance status.");
        }

        var advance = await _db.Advances
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (advance is null)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Advance request not found.");
        }

        advance.Status = request.Status;

        if (request.Status == AdvanceStatus.Pending)
        {
            advance.ApprovedByUserId = null;
            advance.ApprovedAtUtc = null;
        }
        else
        {
            advance.ApprovedByUserId = request.ApprovedByUserId;
            advance.ApprovedAtUtc = DateTime.UtcNow;
        }

        advance.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AdvanceResponse>.Ok(ToResponse(advance));
    }

    public async Task<HRServiceResult<AdvanceSettingsResponse>> CreateAdvanceSettingsAsync(Guid tenantId, CreateAdvanceSettingsRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("TenantId is required.");
        }

        if (request.MaxAdvanceAmountPerPerson < 0)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("MaxAdvanceAmountPerPerson cannot be negative.");
        }

        if (request.MaxAdvanceCountPerYear < 0)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("MaxAdvanceCountPerYear cannot be negative.");
        }

        var normalizedBranchId = NormalizeBranchId(request.BranchId);

        var exists = await _db.AdvanceSettings
            .AsNoTracking()
            .AnyAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == normalizedBranchId,
                ct);

        if (exists)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Conflict("Advance settings already exist for this tenant scope.");
        }

        var now = DateTime.UtcNow;
        var setting = new TechSupport.Hr.Domain.AdvanceSetting
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = normalizedBranchId,
            MaxAdvanceAmountPerPerson = decimal.Round(request.MaxAdvanceAmountPerPerson, 2),
            MaxAdvanceCountPerYear = request.MaxAdvanceCountPerYear,
            AllowFutureAdvances = request.AllowFutureAdvances,
            IsActive = true,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.AdvanceSettings.Add(setting);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AdvanceSettingsResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<AdvanceSettingsResponse>> UpdateAdvanceSettingsAsync(Guid tenantId, Guid id, UpdateAdvanceSettingsRequest request, CancellationToken ct)
    {
        var setting = await _db.AdvanceSettings
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (setting is null)
        {
            return HRServiceResult<AdvanceSettingsResponse>.NotFound("Advance settings not found.");
        }

        if (request.MaxAdvanceAmountPerPerson.HasValue && request.MaxAdvanceAmountPerPerson.Value < 0)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("MaxAdvanceAmountPerPerson cannot be negative.");
        }

        if (request.MaxAdvanceCountPerYear.HasValue && request.MaxAdvanceCountPerYear.Value < 0)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("MaxAdvanceCountPerYear cannot be negative.");
        }

        if (request.BranchId.HasValue)
        {
            var normalizedBranchId = NormalizeBranchId(request.BranchId);
            if (normalizedBranchId != setting.BranchId)
            {
                var exists = await _db.AdvanceSettings
                    .AsNoTracking()
                    .AnyAsync(x =>
                        x.Id != id &&
                        x.TenantId == tenantId &&
                        x.BranchId == normalizedBranchId,
                        ct);

                if (exists)
                {
                    return HRServiceResult<AdvanceSettingsResponse>.Conflict("Advance settings already exist for this tenant scope.");
                }

                setting.BranchId = normalizedBranchId;
            }
        }

        if (request.MaxAdvanceAmountPerPerson.HasValue)
        {
            setting.MaxAdvanceAmountPerPerson = decimal.Round(request.MaxAdvanceAmountPerPerson.Value, 2);
        }

        if (request.MaxAdvanceCountPerYear.HasValue)
        {
            setting.MaxAdvanceCountPerYear = request.MaxAdvanceCountPerYear.Value;
        }

        if (request.AllowFutureAdvances.HasValue)
        {
            setting.AllowFutureAdvances = request.AllowFutureAdvances.Value;
        }

        setting.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AdvanceSettingsResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<AdvanceSettingsResponse>> GetAdvanceSettingsByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var setting = await _db.AdvanceSettings
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return setting is null
            ? HRServiceResult<AdvanceSettingsResponse>.NotFound("Advance settings not found.")
            : HRServiceResult<AdvanceSettingsResponse>.Ok(ToResponse(setting));
    }

    public async Task<HRServiceResult<AdvanceSettingsResponse>> GetCurrentAdvanceSettingsAsync(Guid tenantId, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<AdvanceSettingsResponse>.Fail("TenantId is required.");
        }

        var setting = await _db.AdvanceSettings
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.IsActive)
            .OrderByDescending(x => x.UpdatedAtUtc ?? x.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        return setting is null
            ? HRServiceResult<AdvanceSettingsResponse>.NotFound("Advance settings not found.")
            : HRServiceResult<AdvanceSettingsResponse>.Ok(ToResponse(setting));
    }

    private static Guid? NormalizeBranchId(Guid? branchId)
        => !branchId.HasValue || branchId.Value == Guid.Empty ? null : branchId;

    private static AdvanceResponse ToResponse(Advance advance)
        => new(
            advance.Id,
            advance.TenantId,
            advance.BranchId,
            advance.DepartmentId,
            advance.EmployeeId,
            advance.Amount,
            advance.Reason,
            advance.Status,
            advance.ApprovedByUserId,
            advance.ApprovedAtUtc,
            advance.CreatedAtUtc,
            advance.UpdatedAtUtc);

    private static AdvanceSettingsResponse ToResponse(TechSupport.Hr.Domain.AdvanceSetting setting)
        => new(
            setting.Id,
            setting.TenantId,
            setting.BranchId,
            setting.MaxAdvanceAmountPerPerson,
            setting.MaxAdvanceCountPerYear,
            setting.AllowFutureAdvances,
            setting.CreatedAtUtc,
            setting.UpdatedAtUtc);
}
