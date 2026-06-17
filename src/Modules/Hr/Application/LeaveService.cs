using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface ILeaveService
{
    Task<HRServiceResult<LeaveResponse>> CreateAsync(Guid tenantId, CreateLeaveRequest request, CancellationToken ct);
    Task<HRServiceResult<LeaveResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<LargeLeaveResponseList>> ListAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? employeeId,
        LeaveStatus? status,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct);

    Task<HRServiceResult<LeaveResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateLeaveRequest request, CancellationToken ct);
    Task<HRServiceResult<LeaveResponse>> DecideAsync(Guid tenantId, Guid id, DecideLeaveRequest request, CancellationToken ct);
}

public sealed class LeaveService : ILeaveService
{
    private readonly HRDbContext _db;

    public LeaveService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<LeaveResponse>> CreateAsync(Guid tenantId, CreateLeaveRequest request, CancellationToken ct)
    {
        //!  branch ve departmenidleri opsiyonel bypass
        if (tenantId == Guid.Empty )
        {
            return HRServiceResult<LeaveResponse>.Fail("TenantId is required.");
        }

        if (request.EmployeeId == Guid.Empty )
        {
            return HRServiceResult<LeaveResponse>.Fail("EmployeeId is required.");
        }

        if (request.StartDate.Date > request.EndDate.Date)
        {
            return HRServiceResult<LeaveResponse>.Fail("StartDate must be earlier than or equal to EndDate.");
        }

        if (string.IsNullOrWhiteSpace(request.Reason))
        {
            return HRServiceResult<LeaveResponse>.Fail("Reason is required.");
        }

        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.EmployeeId &&
                x.TenantId == tenantId &&
                //!x.BranchId == request.BranchId
                
                x.DeletedAtUtc == null,
                ct);

        if (employee is null)
        {
            return HRServiceResult<LeaveResponse>.NotFound("Employee not found.");
        }

        // var departmentExists = await _db.Departments
        //     .AsNoTracking()
        //     .AnyAsync(x => x.Id == request.DepartmentId && x.TenantId == tenantId, ct);

        // if (!departmentExists)
        // {
        //     return HRServiceResult<LeaveResponse>.NotFound("Department not found.");
        // }

        // if (employee.DepartmentId.HasValue && employee.DepartmentId.Value != request.DepartmentId)
        // {
        //     return HRServiceResult<LeaveResponse>.Fail("DepartmentId does not match employee department.");
        // }

        var startDate = request.StartDate.Date;
        var endDate = request.EndDate.Date;

        var overlaps = await _db.Leaves
            .AsNoTracking()
            .AnyAsync(x =>
                x.TenantId == tenantId &&
                x.EmployeeId == request.EmployeeId &&
                x.Status != LeaveStatus.Rejected &&
                x.StartDate.Date <= endDate &&
                x.EndDate.Date >= startDate,
                ct);

        if (overlaps)
        {
            return HRServiceResult<LeaveResponse>.Conflict("Leave date range overlaps with an existing leave.");
        }

        if(request.Type == LeaveType.UnpaidLeave)
        {
            var unpaidLeaveDeduction = await _db.LeaveDeductions
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.TenantId == tenantId &&
                    //!x.BranchId == request.BranchId
                    x.DeductionType == LeaveType.UnpaidLeave,
                    ct);

            if (unpaidLeaveDeduction is null)
            {
                return HRServiceResult<LeaveResponse>.NotFound("Unpaid leave deduction configuration not found.");
            }

            request = request with { LeaveDeductionId = unpaidLeaveDeduction.Id };
        }

        var now = DateTime.UtcNow;
        var leave = new Leave
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId ?? Guid.Empty,
            DepartmentId = request.DepartmentId ?? null,
            EmployeeId = request.EmployeeId,
            StartDate = startDate,
            EndDate = endDate,
            Type = request.Type,
            Reason = request.Reason.Trim(),
            Status = LeaveStatus.Pending,
            CreatedAtUtc = now,
            UpdatedAtUtc = now,
            LeaveDeductionId = request.LeaveDeductionId ?? null
        };

        _db.Leaves.Add(leave);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<LeaveResponse>.Ok(ToResponse(leave));
    }

    public async Task<HRServiceResult<LeaveResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var leave = await _db.Leaves
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return leave is null
            ? HRServiceResult<LeaveResponse>.NotFound("Leave record not found.")
            : HRServiceResult<LeaveResponse>.Ok(ToResponse(leave));
    }

    public async Task<HRServiceResult<LargeLeaveResponseList>> ListAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? employeeId,
        LeaveStatus? status,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct)
    {
        // if (branchId.HasValue && branchId.Value == Guid.Empty)
        // {
        //     return HRServiceResult<IReadOnlyCollection<LeaveResponse>>.Fail("BranchId is required.");
        // }

        if (startDate.HasValue && endDate.HasValue && startDate.Value.Date > endDate.Value.Date)
        {
            return HRServiceResult<LargeLeaveResponseList>.Fail("startDate must be earlier than or equal to endDate.");
        }
        //! branchid bypass
        var query = _db.Leaves.Include(x => x.Employee)
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

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
            query = query.Where(x => x.EndDate.Date >= fromDate);
        }

        if (endDate.HasValue)
        {
            var toDate = endDate.Value.Date;
            query = query.Where(x => x.StartDate.Date <= toDate);
        }

        var leaves = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
        var totalLeaves = leaves.Select( x=> ToResponse(x)).ToList();
        var pendingLeaves = leaves.Where(x => x.Status == LeaveStatus.Pending).Select(x => ToResponse(x)).ToList();
        var approvedLeaves = leaves.Where(x => x.Status == LeaveStatus.Approved).Select(x => ToResponse(x)).ToList();
        var rejectedLeaves = leaves.Where(x => x.Status == LeaveStatus.Rejected).Select(x => ToResponse(x)).ToList();

        var largeLeaveResponseList = new LargeLeaveResponseList(
            AllLeaves: totalLeaves,
            PendingLeaves: pendingLeaves,
            ApprovedLeaves: approvedLeaves,
            RejectedLeaves: rejectedLeaves
        );

        return HRServiceResult<LargeLeaveResponseList>.Ok(largeLeaveResponseList);
    }

    public async Task<HRServiceResult<LeaveResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateLeaveRequest request, CancellationToken token)
    {
        if (request.Status.HasValue && !Enum.IsDefined(typeof(LeaveStatus), request.Status.Value))
        {
            return HRServiceResult<LeaveResponse>.Fail("Invalid leave status.");
        }

        var leave = await _db.Leaves
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, token);

        if (leave is null)
        {
            return HRServiceResult<LeaveResponse>.NotFound("Leave record not found.");
        }

        if (request.StartDate.HasValue || request.EndDate.HasValue)
        {
            var nextStart = request.StartDate?.Date ?? leave.StartDate.Date;
            var nextEnd = request.EndDate?.Date ?? leave.EndDate.Date;

            if (nextStart > nextEnd)
            {
                return HRServiceResult<LeaveResponse>.Fail("StartDate must be earlier than or equal to EndDate.");
            }

            var overlapExists = await _db.Leaves
                .AsNoTracking()
                .AnyAsync(x =>
                    x.TenantId == tenantId &&
                    x.EmployeeId == leave.EmployeeId &&
                    x.Id != leave.Id &&
                    x.Status != LeaveStatus.Rejected &&
                    x.StartDate.Date <= nextEnd &&
                    x.EndDate.Date >= nextStart,
                    token);

            if (overlapExists)
            {
                return HRServiceResult<LeaveResponse>.Conflict("Leave date range overlaps with an existing leave.");
            }
        }

        leave.StartDate = request.StartDate ?? leave.StartDate;
        leave.EndDate = request.EndDate ?? leave.EndDate;
        leave.Reason = request.Reason ?? leave.Reason;
        leave.Type = request.Type ?? leave.Type;
        leave.Status = request.Status ?? leave.Status;
        leave.LeaveDeductionId = request.LeaveDeductionId ?? leave.LeaveDeductionId;
        leave.UpdatedAtUtc = DateTime.UtcNow;

        _db.Leaves.Update(leave);
        await _db.SaveChangesAsync(token);

        return HRServiceResult<LeaveResponse>.Ok(ToResponse(leave));
    }

    public async Task<HRServiceResult<LeaveResponse>> DecideAsync(Guid tenantId, Guid id, DecideLeaveRequest request, CancellationToken ct)
    {
        if (!Enum.IsDefined(typeof(LeaveStatus), request.Status))
        {
            return HRServiceResult<LeaveResponse>.Fail("Invalid leave status.");
        }

        var leave = await _db.Leaves.Include(x => x.Employee)
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (leave is null)
        {
            return HRServiceResult<LeaveResponse>.NotFound("Leave record not found.");
        }

        leave.Status = request.Status;

        if (request.Status == LeaveStatus.Pending)
        {
            leave.ApprovedByUserId = null;
            leave.ApprovedAtUtc = null;
        }
        else
        {
            leave.ApprovedByUserId = request.ApprovedByUserId;
            leave.ApprovedAtUtc = DateTime.UtcNow;
        }

        leave.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<LeaveResponse>.Ok(ToResponse(leave));
    }

    private static LeaveResponse ToResponse(Leave leave)
        => new(
            leave.Id,
            leave.TenantId,
            leave.BranchId,
            leave.DepartmentId ?? Guid.Empty,
            leave.EmployeeId,
            leave.Employee?.FullName ?? string.Empty,
            leave.StartDate,
            leave.EndDate,
            leave.Type,
            leave.Reason,
            leave.Status,
            leave.ApprovedByUserId,
            leave.ApprovedAtUtc,
            leave.CreatedAtUtc,
            leave.UpdatedAtUtc);
}
