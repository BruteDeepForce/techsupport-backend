using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IEmployeeService
{
    Task<HRServiceResult<EmployeeResponse>> CreateAsync(Guid tenantId, Guid branchId, CreateEmployeeRequest request, CancellationToken ct);
    Task<HRServiceResult<EmployeeDetailResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<EmployeeLargeDetailResponse>> ListAsync(Guid tenantId, Guid? branchId, CancellationToken ct);
    Task<HRServiceResult<EmployeeResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateEmployeeRequest request, CancellationToken ct);
    Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct);
}

public sealed class EmployeeService : IEmployeeService
{
    private readonly HRDbContext _db;

    public EmployeeService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<EmployeeResponse>> CreateAsync(Guid tenantId, Guid branchId, CreateEmployeeRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty || branchId == Guid.Empty)
        {
            return HRServiceResult<EmployeeResponse>.Fail("TenantId and BranchId are required.");
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return HRServiceResult<EmployeeResponse>.Fail("FullName is required.");
        }

        var employeeNo = string.IsNullOrWhiteSpace(request.EmployeeNo)
            ? GenerateEmployeeNo()
            : request.EmployeeNo.Trim();

        var exists = await _db.Employees
            .AnyAsync(x => x.TenantId == tenantId && x.EmployeeNo == employeeNo && x.DeletedAtUtc == null, ct);

        if (exists)
        {
            return HRServiceResult<EmployeeResponse>.Conflict("EmployeeNo already exists.");
        }

        var now = DateTime.UtcNow;
        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            EmployeeNo = employeeNo,
            FullName = request.FullName.Trim(),
            Email = request.Email?.Trim(),
            Phone = request.Phone?.Trim(),
            ProfileImageUrl = request.ProfileImageUrl?.Trim(),
            DepartmentId = request.DepartmentId,
            PositionId = request.PositionId,
            UserId = request.UserId,
            JobsStartDateUtc = request.JobsStartDateUtc,
            JobsEndDateUtc = request.JobsEndDateUtc,
            Status = EmployeeStatus.Active,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.Employees.Add(employee);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<EmployeeResponse>.Ok(ToResponse(employee));
    }

    public async Task<HRServiceResult<EmployeeDetailResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var employee = await _db.Employees
            .Include(x => x.Position)
            .Include(x => x.EmployeeLeaves)
            .Include(x => x.EmployeeAdvances)
            .Include(x => x.DisciplineEmployeeRecords)
            .Include(x => x.RewardEmployeeRecords)
            .Include(x => x.EmployeeSalaries)
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId && x.DeletedAtUtc == null, ct);

        return employee is null
            ? HRServiceResult<EmployeeDetailResponse>.NotFound("Employee not found.")
            : HRServiceResult<EmployeeDetailResponse>.Ok(ToDetailResponse(employee));
    }

    public async Task<HRServiceResult<EmployeeLargeDetailResponse>> ListAsync(Guid tenantId, Guid? branchId, CancellationToken ct)
    {
        var baseQuery = _db.Employees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.DeletedAtUtc == null);

        var now = DateTime.UtcNow;

        var totalCount = await baseQuery.CountAsync(ct);
        var activeCount = await baseQuery.Where(x => x.Status == EmployeeStatus.Active).CountAsync(ct);
        var passiveCount = await baseQuery.Where(x => x.Status == EmployeeStatus.Passive).CountAsync(ct);
        var employeesOnLeaveCount = await baseQuery
            .Where(x => x.EmployeeLeaves.Any(l => l.Status == LeaveStatus.Approved && l.StartDate <= now && l.EndDate >= now))
            .CountAsync(ct);
        var pendingLeavesCount = await baseQuery
            .Where(x => x.EmployeeLeaves.Any(l => l.Status == LeaveStatus.Pending))
            .CountAsync(ct);
        var pendingAdvanceRequestsCount = await baseQuery
            .Where(x => x.EmployeeAdvances.Any(a => a.Status == AdvanceStatus.Pending))
            .CountAsync(ct);

        var employees = await _db.Employees
            .Include(x => x.Position)
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.DeletedAtUtc == null)
            .OrderBy(x => x.FullName)
            .ToListAsync(ct);

        var response = new EmployeeLargeDetailResponse(
            employees.Select(ToResponse).ToList(),
            totalCount,
            activeCount,
            passiveCount,
            employeesOnLeaveCount,
            pendingLeavesCount,
            pendingAdvanceRequestsCount
        );

        return HRServiceResult<EmployeeLargeDetailResponse>.Ok(response);
    }

    public async Task<HRServiceResult<EmployeeResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateEmployeeRequest request, CancellationToken ct)
    {
        var employee = await _db.Employees
            .Include(x => x.Position)
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId && x.DeletedAtUtc == null, ct);

        if (employee is null)
        {
            return HRServiceResult<EmployeeResponse>.NotFound("Employee not found.");
        }

        if (!string.IsNullOrWhiteSpace(request.FullName))
        {
            employee.FullName = request.FullName.Trim();
        }

        employee.DepartmentId = request.DepartmentId;
        employee.PositionId = request.PositionId;
        employee.UserId = request.UserId;
        employee.Email = request.Email?.Trim();
        employee.Phone = request.Phone?.Trim();
        employee.ProfileImageUrl = request.ProfileImageUrl?.Trim();
        employee.JobsStartDateUtc = request.JobsStartDateUtc;
        employee.JobsEndDateUtc = request.JobsEndDateUtc;

        if (request.IsActive.HasValue)
        {
            employee.Status = request.IsActive.Value ? EmployeeStatus.Active : EmployeeStatus.Passive;
        }

        employee.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<EmployeeResponse>.Ok(ToResponse(employee));
    }

    public async Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var employee = await _db.Employees
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId && x.DeletedAtUtc == null, ct);

        if (employee is null)
        {
            return HRServiceResult<bool>.NotFound("Employee not found.");
        }

        employee.DeletedAtUtc = DateTime.UtcNow;
        employee.UpdatedAtUtc = DateTime.UtcNow;
        employee.Status = EmployeeStatus.Terminated;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<bool>.Ok(true);
    }

    private static EmployeeResponse ToResponse(Employee employee)
        => new(
            employee.Id,
            employee.TenantId,
            employee.BranchId,
            employee.EmployeeNo,
            employee.FullName,
            employee.DepartmentId,
            employee.PositionId,
            employee.Position?.Name,
            employee.UserId,
            employee.Email,
            employee.Phone,
            employee.ProfileImageUrl,
            employee.Status,
            employee.JobsStartDateUtc,
            employee.JobsEndDateUtc,
            employee.CreatedAtUtc,
            employee.UpdatedAtUtc,
            employee.DeletedAtUtc
        );

    private static EmployeeDetailResponse ToDetailResponse(Employee employee)
        => new(
            employee.Id,
            employee.TenantId,
            employee.BranchId,
            employee.EmployeeNo,
            employee.FullName,
            employee.DepartmentId,
            employee.PositionId,
            employee.Position?.Name,
            employee.UserId,
            employee.Email,
            employee.Phone,
            employee.ProfileImageUrl,
            employee.Status,
            employee.JobsStartDateUtc ?? employee.CreatedAtUtc, // Fallback to CreatedAt if JobsStartDate is null
            employee.JobsEndDateUtc,
            employee.CreatedAtUtc,
            employee.UpdatedAtUtc,
            employee.DeletedAtUtc,
            employee.EmployeeLeaves
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new LeaveResponse(
                    x.Id,
                    x.TenantId,
                    x.BranchId,
                    x.DepartmentId ?? Guid.Empty,
                    x.EmployeeId,
                    employee.FullName,
                    x.StartDate,
                    x.EndDate,
                    x.Type,
                    x.Reason,
                    x.Status,
                    x.ApprovedByUserId,
                    x.ApprovedAtUtc,
                    x.CreatedAtUtc,
                    x.UpdatedAtUtc))
                .ToList(),
            employee.EmployeeAdvances
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new AdvanceResponse(
                    x.Id,
                    x.TenantId,
                    x.BranchId,
                    x.DepartmentId,
                    x.EmployeeId,
                    x.Amount,
                    x.Reason,
                    x.Status,
                    x.ApprovedByUserId,
                    x.ApprovedAtUtc,
                    x.CreatedAtUtc,
                    x.UpdatedAtUtc))
                .ToList(),
            employee.DisciplineEmployeeRecords
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new DisciplineEmployeeRecordResponse(
                    x.Id,
                    x.TenantId,
                    x.BranchId,
                    x.EmployeeId,
                    x.DisciplineId,
                    x.Description,
                    x.IncidentDate,
                    x.CreatedAtUtc))
                .ToList(),
            employee.RewardEmployeeRecords
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new RewardEmployeeRecordResponse(
                    x.Id,
                    x.TenantId,
                    x.BranchId,
                    x.EmployeeId,
                    x.RewardId,
                    x.Description,
                    x.RewardDate,
                    x.CreatedAtUtc))
                .ToList(),
            employee.EmployeeSalaries
                .OrderByDescending(x => x.EffectiveFrom)
                .Select(x => new EmployeeSalaryResponse(
                    x.Id,
                    x.TenantId,
                    x.BranchId,
                    x.EmployeeId,
                    x.GrossSalary,
                    x.NetSalary,
                    x.EffectiveFrom,
                    x.EffectiveTo,
                    x.CreatedAtUtc))
                .ToList()
        );

    private static string GenerateEmployeeNo()
        => $"EMP-{DateTime.UtcNow:yyyyMMddHHmmssfff}";
}
