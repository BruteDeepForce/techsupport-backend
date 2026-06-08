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
        if (tenantId == Guid.Empty || request.BranchId == Guid.Empty)
        {
            return HRServiceResult<AdvanceResponse>.Fail("TenantId and BranchId are required.");
        }

        if (request.EmployeeId == Guid.Empty || request.DepartmentId == Guid.Empty)
        {
            return HRServiceResult<AdvanceResponse>.Fail("EmployeeId and DepartmentId are required.");
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
                x.BranchId == request.BranchId &&
                x.DeletedAtUtc == null,
                ct);

        if (employee is null)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Employee not found.");
        }

        var departmentExists = await _db.Departments
            .AsNoTracking()
            .AnyAsync(x => x.Id == request.DepartmentId && x.TenantId == tenantId, ct);

        if (!departmentExists)
        {
            return HRServiceResult<AdvanceResponse>.NotFound("Department not found.");
        }

        if (employee.DepartmentId.HasValue && employee.DepartmentId.Value != request.DepartmentId)
        {
            return HRServiceResult<AdvanceResponse>.Fail("DepartmentId does not match employee department.");
        }

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
}
