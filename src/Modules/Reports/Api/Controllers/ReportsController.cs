using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Reports.Services;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Api.Controllers;

[ApiController]
[Route("api/reports")]
public class ReportsController : ControllerBase
{
    private readonly IReportQueryService _reports;

    public ReportsController(IReportQueryService reports)
    {
        _reports = reports;
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> List([FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var result = await _reports.TenantReportSummaryAsync(tenantId.Value, page, pageSize, ct);
        return Ok(result);
    }
    [Authorize]
    [HttpGet("technicians/summary")]
    public async Task<IActionResult> AllTechnicianSummary(CancellationToken ct = default)
    {        
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();    
        var result = await _reports.AllTechnicianSummaryAsync(tenantId.Value, ct);
        return Ok(result);
    }

    [Authorize]
    [HttpGet("technicians/summary/single")]
    public async Task<IActionResult> SingleTechnicianSummary([FromQuery] Guid technicianUserId, CancellationToken ct = default)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        var result = await _reports.SingleTechnicianSummaryAsync(tenantId.Value, technicianUserId, ct);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [Authorize]
    [HttpGet("metrics")]
    public async Task<IActionResult> Metrics(CancellationToken ct = default)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        var result = await _reports.GetAllReportMetricsAsync(tenantId.Value, ct);
        return Ok(result);
    }

    [Authorize]
    [HttpGet("metrics/single")]
    public async Task<IActionResult> SingleMetric([FromQuery] ReportMetricType metricType,
        [FromQuery] ReportPeriodType periodType,
        [FromQuery] DateOnly? periodDate,
        CancellationToken ct = default)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        var result = await _reports.GetReportMetricAsync(tenantId.Value, metricType, periodType, periodDate, ct);
        if (result == null) return NotFound();
        return Ok(result);
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }
}
