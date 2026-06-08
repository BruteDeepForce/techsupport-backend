using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IEmployeeSalaryService
{
    Task<HRServiceResult<EmployeeSalaryResponse>> CreateAsync(Guid tenantId, CreateEmployeeSalaryRequest request, CancellationToken ct);
    Task<HRServiceResult<EmployeeSalaryResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<EmployeeSalaryResponse>>> ListAsync(Guid tenantId, Guid branchId, Guid? employeeId, CancellationToken ct);
    Task<HRServiceResult<EmployeeSalaryResponse>> GetCurrentByEmployeeAsync(Guid tenantId, Guid employeeId, DateTime? asOfDate, CancellationToken ct);
    Task<HRServiceResult<EmployeeSalaryResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateEmployeeSalaryRequest request, CancellationToken ct);
}

public sealed class EmployeeSalaryService : IEmployeeSalaryService
{
    private readonly HRDbContext _db;

    public EmployeeSalaryService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<EmployeeSalaryResponse>> CreateAsync(Guid tenantId, CreateEmployeeSalaryRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty || request.BranchId == Guid.Empty || request.EmployeeId == Guid.Empty)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("TenantId, BranchId and EmployeeId are required.");
        }

        if (request.GrossSalary <= 0 || request.NetSalary <= 0)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("GrossSalary and NetSalary must be greater than zero.");
        }

        var effectiveFrom = request.EffectiveFrom.Date;  //! yeni maaş kaydı
        var effectiveTo = request.EffectiveTo?.Date; //! yeni maaş kaydnın bitiş tarihi nullable

        if (effectiveTo.HasValue && effectiveTo.Value < effectiveFrom)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("EffectiveTo must be later than or equal to EffectiveFrom.");
        }

        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.EmployeeId &&
                x.TenantId == tenantId &&
                x.BranchId == request.BranchId &&
                x.DeletedAtUtc == null,
                ct);

        if (employee is null)
        {
            return HRServiceResult<EmployeeSalaryResponse>.NotFound("Employee not found.");
        }

        var hasOverlap = await _db.EmployeeSalaries
            .AsNoTracking()
            .AnyAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == request.BranchId &&
                x.EmployeeId == request.EmployeeId &&
                RangesOverlap(x.EffectiveFrom, x.EffectiveTo, effectiveFrom, effectiveTo),
                ct);

        if (hasOverlap)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Conflict("Salary range overlaps with an existing record.");
        }

        var salary = new EmployeeSalary
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            EmployeeId = request.EmployeeId,
            GrossSalary = decimal.Round(request.GrossSalary, 2),
            NetSalary = decimal.Round(request.NetSalary, 2),
            EffectiveFrom = effectiveFrom,
            EffectiveTo = effectiveTo,
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.EmployeeSalaries.Add(salary);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<EmployeeSalaryResponse>.Ok(ToResponse(salary));
    }

    public async Task<HRServiceResult<EmployeeSalaryResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var salary = await _db.EmployeeSalaries
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return salary is null
            ? HRServiceResult<EmployeeSalaryResponse>.NotFound("Employee salary not found.")
            : HRServiceResult<EmployeeSalaryResponse>.Ok(ToResponse(salary));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<EmployeeSalaryResponse>>> ListAsync(Guid tenantId, Guid branchId, Guid? employeeId, CancellationToken ct)
    {
        if (branchId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<EmployeeSalaryResponse>>.Fail("BranchId is required.");
        }

        var query = _db.EmployeeSalaries
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId);
        

        if (employeeId.HasValue && employeeId.Value != Guid.Empty)
        {
            query = query.Where(x => x.EmployeeId == employeeId.Value);
        }

        var items = await query
            .OrderBy(x => x.EmployeeId)
            .ThenByDescending(x => x.EffectiveFrom)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<EmployeeSalaryResponse>>.Ok(items.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<EmployeeSalaryResponse>> GetCurrentByEmployeeAsync(Guid tenantId, Guid employeeId, DateTime? asOfDate, CancellationToken ct)
    {
        if (employeeId == Guid.Empty)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("EmployeeId is required.");
        }

        var targetDate = (asOfDate ?? DateTime.UtcNow).Date;

        var salary = await _db.EmployeeSalaries
            .AsNoTracking()
            .Where(x =>
                x.TenantId == tenantId &&
                x.EmployeeId == employeeId &&
                x.EffectiveFrom <= targetDate &&
                (x.EffectiveTo == null || x.EffectiveTo >= targetDate))
            .OrderByDescending(x => x.EffectiveFrom)
            .FirstOrDefaultAsync(ct);

        return salary is null
            ? HRServiceResult<EmployeeSalaryResponse>.NotFound("Active salary record not found for employee/date.")
            : HRServiceResult<EmployeeSalaryResponse>.Ok(ToResponse(salary));
    }

    public async Task<HRServiceResult<EmployeeSalaryResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateEmployeeSalaryRequest request, CancellationToken ct)
    {
        var salary = await _db.EmployeeSalaries
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (salary is null)
        {
            return HRServiceResult<EmployeeSalaryResponse>.NotFound("Employee salary not found.");
        }

        if (request.GrossSalary.HasValue && request.GrossSalary.Value <= 0)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("GrossSalary must be greater than zero.");
        }

        if (request.NetSalary.HasValue && request.NetSalary.Value <= 0)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("NetSalary must be greater than zero.");
        }

        var effectiveFrom = request.EffectiveFrom?.Date ?? salary.EffectiveFrom.Date;
        var effectiveTo = request.EffectiveTo?.Date ?? salary.EffectiveTo?.Date;

        if (effectiveTo.HasValue && effectiveTo.Value < effectiveFrom)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Fail("EffectiveTo must be later than or equal to EffectiveFrom.");
        }

        var hasOverlap = await _db.EmployeeSalaries
            .AsNoTracking()
            .AnyAsync(x =>
                x.Id != salary.Id &&
                x.TenantId == tenantId &&
                x.BranchId == salary.BranchId &&
                x.EmployeeId == salary.EmployeeId &&
                RangesOverlap(x.EffectiveFrom, x.EffectiveTo, effectiveFrom, effectiveTo),
                ct);

        if (hasOverlap)
        {
            return HRServiceResult<EmployeeSalaryResponse>.Conflict("Updated salary range overlaps with an existing record.");
        }

        if (request.GrossSalary.HasValue)
        {
            salary.GrossSalary = decimal.Round(request.GrossSalary.Value, 2);
        }

        if (request.NetSalary.HasValue)
        {
            salary.NetSalary = decimal.Round(request.NetSalary.Value, 2);
        }

        salary.EffectiveFrom = effectiveFrom;
        salary.EffectiveTo = effectiveTo;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<EmployeeSalaryResponse>.Ok(ToResponse(salary));
    }

    private static bool RangesOverlap(DateTime start1, DateTime? end1, DateTime start2, DateTime? end2)
    {
        var leftEnd = end1 ?? DateTime.MaxValue.Date;
        var rightEnd = end2 ?? DateTime.MaxValue.Date;

        return start1.Date <= rightEnd && start2.Date <= leftEnd;
    }

    private static EmployeeSalaryResponse ToResponse(EmployeeSalary salary)
        => new(
            salary.Id,
            salary.TenantId,
            salary.BranchId,
            salary.EmployeeId,
            salary.GrossSalary,
            salary.NetSalary,
            salary.EffectiveFrom,
            salary.EffectiveTo,
            salary.CreatedAtUtc);
}
