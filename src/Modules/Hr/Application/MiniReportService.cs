using Microsoft.EntityFrameworkCore;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IMiniReportService
{
    Task<HRServiceResult<LeaveAndAdvanceResponse>> LeaveAndAdvancesByDepartmentID(Guid DepartmentID, Guid tenantID, Guid? BranchId, int page, int limit, CancellationToken ct);

    Task<HRServiceResult<LeaveAndAdvanceResponse>> LeaveAndAdvancesByEmployeeUserID(Guid tenantID, Guid? BranchID, Guid UserId, int page, int limit, CancellationToken ct);
}

public class MiniReportService : IMiniReportService
{
    public readonly HRDbContext _db;

    public MiniReportService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<LeaveAndAdvanceResponse>> LeaveAndAdvancesByDepartmentID(Guid DepartmentID, Guid tenantId, Guid? branchId, int page, int limit, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("TenantId is required.");
        }

        if (DepartmentID == Guid.Empty)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("DepartmentId is required.");
        }

        if (page <= 0 || limit <= 0)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("page and limit must be greater than zero.");
        }

        var department = await _db.Departments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == DepartmentID && x.TenantId == tenantId, ct);

        if (department is null)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.NotFound("Department not found.");
        }

        var advancesQuery = _db.Advances
            .AsNoTracking()
            .Where(ad => ad.DepartmentId == DepartmentID && ad.TenantId == tenantId);

        var leavesQuery = _db.Leaves
            .AsNoTracking()
            .Where(le => le.DepartmentId == DepartmentID && le.TenantId == tenantId);

        if (branchId.HasValue && branchId.Value != Guid.Empty)
        {
            advancesQuery = advancesQuery.Where(ad => ad.BranchId == branchId.Value);
            leavesQuery = leavesQuery.Where(le => le.BranchId == branchId.Value);
        }

        var totalAdvances = await advancesQuery.CountAsync(ct);
        var totalLeaves = await leavesQuery.CountAsync(ct);

        var advances = await advancesQuery
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync(ct);

        var leaves = await leavesQuery
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync(ct);

        var leavesDTOs = leaves.Select(le => new LeavesDTO(
            Id: le.Id,
            TenantId: le.TenantId,
            BranchId: le.BranchId,
            DepartmentId: le.DepartmentId ?? Guid.Empty,
            EmployeeId: le.EmployeeId,
            StartDate: le.StartDate,
            EndDate: le.EndDate,
            Type: le.Type,
            Reason: le.Reason,
            Status: le.Status,
            ApprovedByUserId: le.ApprovedByUserId,
            ApprovedAtUtc: le.ApprovedAtUtc,
            CreatedAtUtc: le.CreatedAtUtc,
            UpdatedAtUtc: le.UpdatedAtUtc
        )).ToList();

        var advancesDTOs = advances.Select(ad => new AdvanceDTO(
            Id: ad.Id,
            TenantId: ad.TenantId,
            BranchId: ad.BranchId,
            DepartmentId: ad.DepartmentId,
            EmployeeId: ad.EmployeeId,
            Amount: ad.Amount,
            Reason: ad.Reason,
            Status: ad.Status,
            ApprovedByUserId: ad.ApprovedByUserId,
            ApprovedAtUtc: ad.ApprovedAtUtc,
            CreatedAtUtc: ad.CreatedAtUtc,
            UpdatedAtUtc: ad.UpdatedAtUtc
        )).ToList();

        var leaveAndAdvances = new LeaveAndAdvanceResponse(
            Leaves: leavesDTOs,
            Advances: advancesDTOs,
            Pagination: new MiniReportPagination(
                Page: page,
                Limit: limit,
                TotalLeaves: totalLeaves,
                TotalAdvances: totalAdvances,
                HasNextLeaves: page * limit < totalLeaves,
                HasNextAdvances: page * limit < totalAdvances)
        );

        return HRServiceResult<LeaveAndAdvanceResponse>.Ok(leaveAndAdvances);
    }

    public async Task<HRServiceResult<LeaveAndAdvanceResponse>> LeaveAndAdvancesByEmployeeUserID(Guid tenantID, Guid? BranchID, Guid UserId, int page, int limit, CancellationToken ct)
    {
        if (tenantID == Guid.Empty)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("TenantId is required.");
        }

        if (UserId == Guid.Empty)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("UserId is required.");
        }

        if (page <= 0 || limit <= 0)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.Fail("page and limit must be greater than zero.");
        }

        var employeeQuery = _db.Employees
            .AsNoTracking()
            .Where(em => em.TenantId == tenantID && em.UserId == UserId && em.DeletedAtUtc == null);

        if (BranchID.HasValue && BranchID.Value != Guid.Empty)
        {
            employeeQuery = employeeQuery.Where(em => em.BranchId == BranchID.Value);
        }

        var employee = await employeeQuery.FirstOrDefaultAsync(ct);

        if (employee is null)
        {
            return HRServiceResult<LeaveAndAdvanceResponse>.NotFound("Employee not found.");
        }

        var advancesQuery = _db.Advances
            .AsNoTracking()
            .Where(ad => ad.TenantId == tenantID && ad.EmployeeId == employee.Id);

        var leavesQuery = _db.Leaves
            .AsNoTracking()
            .Where(le => le.TenantId == tenantID && le.EmployeeId == employee.Id);

        if (BranchID.HasValue && BranchID.Value != Guid.Empty)
        {
            advancesQuery = advancesQuery.Where(ad => ad.BranchId == BranchID.Value);
            leavesQuery = leavesQuery.Where(le => le.BranchId == BranchID.Value);
        }

        var totalAdvances = await advancesQuery.CountAsync(ct);
        var totalLeaves = await leavesQuery.CountAsync(ct);

        var advances = await advancesQuery
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync(ct);

        var leaves = await leavesQuery
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync(ct);

        var leavesDTOs = leaves.Select(le => new LeavesDTO(
            Id: le.Id,
            TenantId: le.TenantId,
            BranchId: le.BranchId,
            DepartmentId: le.DepartmentId ?? Guid.Empty,
            EmployeeId: le.EmployeeId,
            StartDate: le.StartDate,
            EndDate: le.EndDate,
            Type: le.Type,
            Reason: le.Reason,
            Status: le.Status,
            ApprovedByUserId: le.ApprovedByUserId,
            ApprovedAtUtc: le.ApprovedAtUtc,
            CreatedAtUtc: le.CreatedAtUtc,
            UpdatedAtUtc: le.UpdatedAtUtc
        )).ToList();

        var advancesDTOs = advances.Select(ad => new AdvanceDTO(
            Id: ad.Id,
            TenantId: ad.TenantId,
            BranchId: ad.BranchId,
            DepartmentId: ad.DepartmentId,
            EmployeeId: ad.EmployeeId,
            Amount: ad.Amount,
            Reason: ad.Reason,
            Status: ad.Status,
            ApprovedByUserId: ad.ApprovedByUserId,
            ApprovedAtUtc: ad.ApprovedAtUtc,
            CreatedAtUtc: ad.CreatedAtUtc,
            UpdatedAtUtc: ad.UpdatedAtUtc
        )).ToList();

        var leaveAndAdvances = new LeaveAndAdvanceResponse(
            Leaves: leavesDTOs,
            Advances: advancesDTOs,
            Pagination: new MiniReportPagination(
                Page: page,
                Limit: limit,
                TotalLeaves: totalLeaves,
                TotalAdvances: totalAdvances,
                HasNextLeaves: page * limit < totalLeaves,
                HasNextAdvances: page * limit < totalAdvances)
        );

        return HRServiceResult<LeaveAndAdvanceResponse>.Ok(leaveAndAdvances);
    }
}