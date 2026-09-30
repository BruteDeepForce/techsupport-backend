using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Contracts;
using TechSupport.Reports.Data;

namespace TechSupport.Reports.Api.Controllers;

[ApiController]
[Route("api/reports/dashboard")]
public sealed class ReportsDashboardController : ControllerBase
{
    private readonly ReportDbContext _db;

    public ReportsDashboardController(ReportDbContext db)
    {
        _db = db;
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null)
            return Unauthorized();

        var summary = await _db.TenantReportSummaries
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId.Value)
            .Select(x => new TenantReportSummaryResponse(
                x.TenantId,
                x.TenantName,
                x.TotalCustomers,
                x.TotalOperations,
                x.CompletedOperations,
                x.FailedOperations,
                x.DeliveredOperations,
                x.OpenOperations,
                x.UpdatedAtUtc))
            .FirstOrDefaultAsync(ct)
            ?? new TenantReportSummaryResponse(
                tenantId.Value,
                string.Empty,
                0,
                0,
                0,
                0,
                0,
                0,
                null);

        var metrics = await _db.TenantReportMetrics
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId.Value)
            .OrderBy(x => x.PeriodStart)
            .Select(x => new TenantReportMetricResponse(
                x.MetricType,
                x.PeriodType,
                x.PeriodStart,
                x.Value,
                x.UpdatedAtUtc))
            .ToListAsync(ct);

        var plannedOperations = await _db.PlannedOperationSnapshots
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId.Value && x.ScheduledAtUtc > DateTimeOffset.UtcNow)
            .OrderBy(x => x.ScheduledAtUtc)
            .Select(x => new PlannedOperationSnapshot
            {
                Id = x.Id,
                TenantId = x.TenantId,
                BranchId = x.BranchId,
                ScheduledAtUtc = x.ScheduledAtUtc,
                ToTechnicianUserId = x.ToTechnicianUserId,
                TechnicianFullName = x.TechnicianFullName,
                CustomerId = x.CustomerId,
                CustomerName = x.CustomerName,
                Title = x.Title,
                Description = x.Description,
                OperationId = x.OperationId
            })
            .ToListAsync(ct);

        return Ok(new TenantDashboardResponse(summary, metrics, plannedOperations));
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId)
            ? tenantId
            : null;
    }
}

public sealed record TenantDashboardResponse(
    TenantReportSummaryResponse Summary,
    IReadOnlyCollection<TenantReportMetricResponse> Metrics,
    IReadOnlyCollection<PlannedOperationSnapshot> PlannedOperations);

public sealed record TenantReportSummaryResponse(
    Guid TenantId,
    string TenantName,
    int TotalCustomers,
    int TotalOperations,
    int CompletedOperations,
    int FailedOperations,
    int DeliveredOperations,
    int OpenOperations,
    DateTimeOffset? UpdatedAtUtc);

public sealed record TenantReportMetricResponse(
    TenantReportMetricType MetricType,
    TenantReportPeriodType PeriodType,
    DateOnly PeriodStart,
    long Value,
    DateTimeOffset UpdatedAtUtc);
