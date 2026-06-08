using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IEmployeeService
{
    Task<HRServiceResult<EmployeeResponse>> CreateAsync(Guid tenantId, Guid branchId, CreateEmployeeRequest request, CancellationToken ct);
    Task<HRServiceResult<EmployeeResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<EmployeeResponse>>> ListAsync(Guid tenantId, Guid branchId, bool includeInactive, CancellationToken ct);
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

    public async Task<HRServiceResult<EmployeeResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId && x.DeletedAtUtc == null, ct);

        return employee is null
            ? HRServiceResult<EmployeeResponse>.NotFound("Employee not found.")
            : HRServiceResult<EmployeeResponse>.Ok(ToResponse(employee));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<EmployeeResponse>>> ListAsync(Guid tenantId, Guid branchId, bool includeInactive, CancellationToken ct)
    {
        var query = _db.Employees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId && x.DeletedAtUtc == null);

        if (!includeInactive)
        {
            query = query.Where(x => x.Status == EmployeeStatus.Active);
        }

        //! pagination eklenecek faz-2 

        var employees = await query
            .OrderBy(x => x.FullName)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<EmployeeResponse>>.Ok(employees.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<EmployeeResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateEmployeeRequest request, CancellationToken ct)
    {
        var employee = await _db.Employees
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
            employee.UserId,
            employee.Email,
            employee.Phone,
            employee.ProfileImageUrl,
            employee.Status,
            employee.JobsStartDateUtc,
            employee.JobsEndDateUtc,
            employee.CreatedAtUtc,
            employee.UpdatedAtUtc,
            employee.DeletedAtUtc);

    private static string GenerateEmployeeNo()
        => $"EMP-{DateTime.UtcNow:yyyyMMddHHmmssfff}";
}
