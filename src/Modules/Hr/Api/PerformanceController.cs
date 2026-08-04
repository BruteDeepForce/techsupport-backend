using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Modules.HR.DTO;
using TechSupport.Hr.Application;
using TechSupport.Hr.Domain;

namespace Modules.HR.Api;

[ApiController]
[Route("api/hr/performance")]
[Authorize]
public sealed class PerformanceController : ControllerBase
{
    private readonly IEmployeePerformanceService _service;

    public PerformanceController(IEmployeePerformanceService service)
    {
        _service = service;
    }

    [HttpGet("employee/{employeeId:guid}")]
    public async Task<IActionResult> GetByEmployee(
        Guid employeeId,
        [FromQuery] int year,
        [FromQuery] int month,
        CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetEmployeePerformanceReportAsync(tenantId, employeeId, year, month, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == Modules.HR.Application.HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(ToResponse(result.Data!));
    }

    [HttpGet("all")]
    public async Task<IActionResult> GetAll(
        [FromQuery] int year,
        [FromQuery] int month,
        CancellationToken ct)
    {
        if (!TryGetTenantId(out var tenantId))
        {
            return Unauthorized("TenantId is required in claim (tenant_id).");
        }

        var result = await _service.GetAllEmployeePerformanceReportsAsync(tenantId, year, month, ct);
        if (!result.Succeeded)
        {
            return result.ErrorType == Modules.HR.Application.HRServiceErrorType.NotFound
                ? NotFound(result.Error)
                : BadRequest(result.Error);
        }

        return Ok(result.Data!.Select(ToResponse));
    }

    private static EmployeePerformanceReportResponse ToResponse(EmployeePerformanceReport report)
        => new(
            report.Id,
            report.EmployeeId,
            report.TenantId,
            report.BranchId,
            report.Year,
            report.Month,
            report.TotalAssignedTasks,
            report.TotalCompletedTasks,
            report.TotalPendingTasks,
            report.TotalOverdueTasks,
            report.TotalCompletedOnTime,
            report.TotalCompletedLate,
            report.RewardCount,
            report.PenaltyCount,
            report.LeaveCount,
            report.ShiftAttendanceCount,
            report.NotJoinedShiftCount,
            report.OvertimeCount);

    private bool TryGetTenantId(out Guid tenantId)
    {
        tenantId = Guid.Empty;
        var claimValue = User.FindFirstValue("tenant_id") ?? User.FindFirstValue("tenantId");
        return Guid.TryParse(claimValue, out tenantId);
    }
}
