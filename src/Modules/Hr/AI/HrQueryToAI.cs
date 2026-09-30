using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.Infrastructure;
using TechSupport.Hr.Contracts.AI;

namespace TechSupport.Hr.AI;

/// <summary>
/// AI modülünün insan kaynakları verisini okumasını sağlayan implementasyon.
/// </summary>
public sealed class HrQueryToAI : IHrQueryToAI
{
    private readonly HRDbContext _db;

    public HrQueryToAI(HRDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyCollection<EmployeeInfoResponse>> QueryEmployeesAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Employees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.DeletedAtUtc == null);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x =>
                EF.Functions.ILike(x.FullName, $"%{term}%") ||
                EF.Functions.ILike(x.EmployeeNo, $"%{term}%") ||
                EF.Functions.ILike(x.Email!, $"%{term}%") ||
                EF.Functions.ILike(x.Phone!, $"%{term}%"));
        }

        return await query
            .OrderBy(x => x.FullName)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new EmployeeInfoResponse(
                x.Id,
                x.EmployeeNo,
                x.FullName,
                x.Department != null ? x.Department.Name : null,
                x.Position != null ? x.Position.Name : null,
                x.Status.ToString(),
                x.Email,
                x.Phone))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<LeaveInfoResponse>> QueryLeavesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Leaves
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (Enum.TryParse<LeaveStatus>(status.Trim(), ignoreCase: true, out var parsed))
            {
                query = query.Where(x => x.Status == parsed);
            }
        }

        return await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new LeaveInfoResponse(
                x.Id,
                x.EmployeeId,
                x.Employee != null ? x.Employee.FullName : null,
                x.Department != null ? x.Department.Name : null,
                x.Type.ToString(),
                x.Status.ToString(),
                x.StartDate,
                x.EndDate,
                x.Reason))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<AdvanceInfoResponse>> QueryAdvancesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Advances
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (Enum.TryParse<AdvanceStatus>(status.Trim(), ignoreCase: true, out var parsed))
            {
                query = query.Where(x => x.Status == parsed);
            }
        }

        return await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new AdvanceInfoResponse(
                x.Id,
                x.EmployeeId,
                x.Employee != null ? x.Employee.FullName : null,
                x.Department != null ? x.Department.Name : null,
                x.Amount,
                x.Status.ToString(),
                x.Reason,
                x.CreatedAtUtc))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<EmployeePerformanceInfoResponse>> QueryEmployeePerformancesAsync(
        Guid tenantId,
        Guid? branchId,
        int? year,
        int? month,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.EmployeePerformanceReports
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (year.HasValue)
        {
            query = query.Where(x => x.Year == year.Value);
        }

        if (month.HasValue)
        {
            query = query.Where(x => x.Month == month.Value);
        }

        return await query
            .OrderByDescending(x => x.Year)
            .ThenByDescending(x => x.Month)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new EmployeePerformanceInfoResponse(
                x.EmployeeId,
                x.Employee != null ? x.Employee.FullName : null,
                x.Employee != null && x.Employee.Department != null ? x.Employee.Department.Name : null,
                x.Year,
                x.Month,
                x.TotalAssignedTasks,
                x.TotalCompletedTasks,
                x.TotalPendingTasks,
                x.TotalOverdueTasks,
                x.RewardCount,
                x.PenaltyCount,
                x.LeaveCount,
                x.NotJoinedShiftCount))
            .ToListAsync(ct);
    }

    public async Task<HrSummaryResponse> GetHrSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default)
    {
        var employeeQuery = _db.Employees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId
                        && x.DeletedAtUtc == null
                        && (!branchId.HasValue || x.BranchId == branchId));

        var totalEmployeeCount = await employeeQuery.CountAsync(ct);
        var activeEmployeeCount = await employeeQuery.CountAsync(x => x.Status == EmployeeStatus.Active, ct);
        var onLeaveEmployeeCount = await employeeQuery.CountAsync(x => x.Status == EmployeeStatus.OnLeave, ct);

        var leaveQuery = _db.Leaves
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId
                        && (!branchId.HasValue || x.BranchId == branchId)
                        && x.Status == LeaveStatus.Pending);

        var pendingLeaveCount = await leaveQuery.CountAsync(ct);

        var advanceQuery = _db.Advances
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && (!branchId.HasValue || x.BranchId == branchId));

        var totalAdvanceAmount = await advanceQuery.SumAsync(x => (decimal?)x.Amount, ct) ?? 0m;
        var pendingAdvanceAmount = await advanceQuery
            .Where(x => x.Status == AdvanceStatus.Pending)
            .SumAsync(x => (decimal?)x.Amount, ct) ?? 0m;

        return new HrSummaryResponse(
            totalEmployeeCount,
            activeEmployeeCount,
            onLeaveEmployeeCount,
            pendingLeaveCount,
            pendingAdvanceAmount,
            totalAdvanceAmount);
    }

    private static (int Page, int PageSize) NormalizePaging(int page, int pageSize)
    {
        var safePage = page < 1 ? 1 : page;
        var safePageSize = pageSize switch
        {
            < 1 => 20,
            > 200 => 200,
            _ => pageSize
        };

        return (safePage, safePageSize);
    }
}