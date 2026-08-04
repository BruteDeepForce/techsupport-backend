using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Modules.HR.Application;
using Modules.HR.Infrastructure;
using TechSupport.Hr.Contracts.Events;
using TechSupport.Hr.Domain;

namespace TechSupport.Hr.Application
{
    public interface IEmployeePerformanceService
    {
        Task<HRServiceResult<EmployeePerformanceReport>> GetEmployeePerformanceReportAsync(Guid tenantId, Guid employeeId, int year, int month, CancellationToken cancellationToken = default);
        Task<HRServiceResult<EmployeePerformanceReport>> CreateOrUpdateEmployeePerformanceReportAsync(PerformanceUpdate request, CancellationToken cancellationToken = default);
    
        Task<HRServiceResult<IEnumerable<EmployeePerformanceReport>>> GetAllEmployeePerformanceReportsAsync(Guid tenantId, int year, int month, CancellationToken cancellationToken = default);
    }

    public class EmployeePerformanceService : IEmployeePerformanceService
    {
        private readonly HRDbContext _context;

        public EmployeePerformanceService(HRDbContext context)
        {
            _context = context;
        }
        
        public async Task<HRServiceResult<EmployeePerformanceReport>> GetEmployeePerformanceReportAsync(Guid tenantId, Guid employeeId, int year, int month, CancellationToken cancellationToken = default)
        {
            if (tenantId == Guid.Empty)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("TenantId is required.");
            }

            if (employeeId == Guid.Empty)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("EmployeeId is required.");
            }

            if (month is < 1 or > 12)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("Month must be between 1 and 12.");
            }

            var report = await _context.EmployeePerformanceReports
                .AsNoTracking()
                .FirstOrDefaultAsync(r =>
                    r.TenantId == tenantId &&
                    r.EmployeeId == employeeId &&
                    r.Year == year &&
                    r.Month == month,
                    cancellationToken);

            if (report == null)
            {
                return HRServiceResult<EmployeePerformanceReport>.NotFound("Employee performance report not found.");
            }

            return HRServiceResult<EmployeePerformanceReport>.Ok(report);
        }

        public async Task<HRServiceResult<IEnumerable<EmployeePerformanceReport>>> GetAllEmployeePerformanceReportsAsync(Guid tenantId, int year, int month, CancellationToken cancellationToken = default)
        {
            if (tenantId == Guid.Empty)
            {
                return HRServiceResult<IEnumerable<EmployeePerformanceReport>>.Fail("TenantId is required.");
            }

            if (month is < 1 or > 12)
            {
                return HRServiceResult<IEnumerable<EmployeePerformanceReport>>.Fail("Month must be between 1 and 12.");
            }

            var reports = await _context.EmployeePerformanceReports
                .AsNoTracking()
                .Where(r =>
                    r.TenantId == tenantId &&
                    r.Year == year &&
                    r.Month == month)
                .ToListAsync(cancellationToken);

            return HRServiceResult<IEnumerable<EmployeePerformanceReport>>.Ok(reports);
        }

        public async Task<HRServiceResult<EmployeePerformanceReport>> CreateOrUpdateEmployeePerformanceReportAsync(PerformanceUpdate request, CancellationToken cancellationToken = default)
        {
            if (request.TenantId == Guid.Empty)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("TenantId is required.");
            }

            if (request.EmployeeId == Guid.Empty)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("EmployeeId is required.");
            }

            if (request.Month is < 1 or > 12)
            {
                return HRServiceResult<EmployeePerformanceReport>.Fail("Month must be between 1 and 12.");
            }

            var employeeExists = await _context.Employees
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Id == request.EmployeeId &&
                    x.TenantId == request.TenantId &&
                    x.DeletedAtUtc == null,
                    cancellationToken);

            if (!employeeExists)
            {
                return HRServiceResult<EmployeePerformanceReport>.NotFound("Employee not found.");
            }

            var report = await _context.EmployeePerformanceReports
                .FirstOrDefaultAsync(r =>
                    r.TenantId == request.TenantId &&
                    r.EmployeeId == request.EmployeeId &&
                    r.Year == request.Year &&
                    r.Month == request.Month,
                    cancellationToken);

            if (report == null)
            {
                report = new EmployeePerformanceReport
                {
                    Id = Guid.NewGuid(),
                    EmployeeId = request.EmployeeId,
                    TenantId = request.TenantId,
                    BranchId = request.BranchId,
                    Year = request.Year,
                    Month = request.Month
                };
                _context.EmployeePerformanceReports.Add(report);
            }
            else if (request.BranchId.HasValue && report.BranchId != request.BranchId)
            {
                report.BranchId = request.BranchId;
            }

            report.TotalAssignedTasks = ApplyDelta(report.TotalAssignedTasks, request.TotalAssignedTasksDelta);
            report.TotalCompletedTasks = ApplyDelta(report.TotalCompletedTasks, request.TotalCompletedTasksDelta);
            report.TotalPendingTasks = ApplyDelta(report.TotalPendingTasks, request.TotalPendingTasksDelta);
            report.TotalOverdueTasks = ApplyDelta(report.TotalOverdueTasks, request.TotalOverdueTasksDelta);
            report.TotalCompletedOnTime = ApplyDelta(report.TotalCompletedOnTime ?? 0, request.TotalCompletedOnTimeDelta);
            report.TotalCompletedLate = ApplyDelta(report.TotalCompletedLate ?? 0, request.TotalCompletedLateDelta);
            report.RewardCount = ApplyDelta(report.RewardCount, request.RewardCountDelta);
            report.PenaltyCount = ApplyDelta(report.PenaltyCount, request.PenaltyCountDelta);
            report.LeaveCount = ApplyDelta(report.LeaveCount, request.LeaveCountDelta);
            report.ShiftAttendanceCount = ApplyDelta(report.ShiftAttendanceCount, request.ShiftAttendanceCountDelta);
            report.NotJoinedShiftCount = ApplyDelta(report.NotJoinedShiftCount, request.NotJoinedShiftCountDelta);
            report.OvertimeCount = ApplyDelta(report.OvertimeCount, request.OvertimeCountDelta);

            await _context.SaveChangesAsync(cancellationToken);

            return HRServiceResult<EmployeePerformanceReport>.Ok(report);
        }

        private static int ApplyDelta(int currentValue, int delta)
        {
            var nextValue = currentValue + delta;
            return nextValue < 0 ? 0 : nextValue;
        }
    }
}
