using System.Runtime.CompilerServices;
using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Data;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public sealed class ReportQueryService : IReportQueryService
{
    private readonly ReportDbContext _db;

    public ReportQueryService(ReportDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyCollection<TechinicianSummaryDto>> AllTechnicianSummaryAsync(Guid tenantId, CancellationToken ct = default)
    {
        var summary = await _db.TechnicianReportSummaries
            .AsNoTracking()
            .Where(t => t.TenantId == tenantId)
            .Select(t => new TechinicianSummaryDto
            {
                TechnicianUserId = t.TechnicianUserId,
                Name = t.Name,
                Email = t.Email,
                PhoneNumber = t.PhoneNumber,
                LastProfileUpdateAtUtc = t.LastProfileUpdateAtUtc
            })
            .ToListAsync(ct);

        if (summary == null)
        {
            // Return an empty summary if no technician found for the tenant. Alternatively, could throw or return null.
            summary = new List<TechinicianSummaryDto>
            {
                new TechinicianSummaryDto
                {
                    TechnicianUserId = Guid.Empty,
                    Name = string.Empty,
                    Email = string.Empty,
                    PhoneNumber = null,
                    LastProfileUpdateAtUtc = null
            }
            };
        }
        return summary;
    }

    public async Task<IReadOnlyCollection<ReportMetricsDTO>> GetAllReportMetricsAsync(Guid tenantId, CancellationToken ct = default)
    {
        var metrics = await _db.ReportMetrics
            .AsNoTracking()
            .Where(m => m.TenantId == tenantId)
            .Select(m => new ReportMetricsDTO
            {
                MetricType = m.MetricType,
                PeriodType = m.PeriodType,
                PeriodDate = m.PeriodDate,
                Value = m.Value,
                CreatedAtUtc = m.CreatedAtUtc,
                UpdatedAtUtc = m.UpdatedAtUtc
            })
            .ToListAsync(ct);
        // Return the (possibly empty) list. Clients should expect an empty list when no metrics exist for the tenant.
        return metrics;
    }

    public async Task<ReportMetricsDTO?> GetReportMetricAsync(Guid tenantId, ReportMetricType metricType, ReportPeriodType periodType, DateOnly? periodDate, CancellationToken ct = default)
    {
        var q = _db.ReportMetrics.AsNoTracking()
            .Where(m => m.TenantId == tenantId && m.MetricType == metricType && m.PeriodType == periodType);

        // periodDate is ignored for AllTime; otherwise require it.
        if (periodType != ReportPeriodType.AllTime)
        {
            if (!periodDate.HasValue)
                return null; // invalid request semantics: period-based metric requires a date

            q = q.Where(m => m.PeriodDate == periodDate.Value);
        }

        var metric = await q
            .Select(m => new ReportMetricsDTO
            {
                MetricType = m.MetricType,
                PeriodType = m.PeriodType,
                PeriodDate = m.PeriodDate,
                Value = m.Value,
                CreatedAtUtc = m.CreatedAtUtc,
                UpdatedAtUtc = m.UpdatedAtUtc
            })
            .FirstOrDefaultAsync(ct);

        // Return null if not found — controller can map to 404 or 200+zero as desired.
        return metric;
    }

    public async Task<TechinicianSummaryDto?> SingleTechnicianSummaryAsync(Guid tenantId, Guid technicianUserId, CancellationToken ct = default)
    {
          var technician = await _db.TechnicianReportSummaries.AsNoTracking()
            .Where(t => t.TenantId == tenantId && t.TechnicianUserId == technicianUserId)
            .Select(t => new TechinicianSummaryDto
            {
                TechnicianUserId = t.TechnicianUserId,
                Name = t.Name,
                Email = t.Email,
                PhoneNumber = t.PhoneNumber,
                LastProfileUpdateAtUtc = t.LastProfileUpdateAtUtc
            })
            .FirstOrDefaultAsync(ct);
            
            return technician;
    }

    public async Task<PagedResult<ReportSummaryDto>> TenantReportSummaryAsync(Guid tenantId, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 200);

        var baseQ = _db.GeneratedReports
            .AsNoTracking()
            .Where(r => r.TenantId == tenantId);

        var total = await baseQ.CountAsync(ct);

        var items = await baseQ
            .OrderByDescending(r => r.GeneratedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new ReportSummaryDto
            {
                Id = r.Id,
                Name = r.Name,
                Description = r.Description,
                GeneratedAtUtc = r.GeneratedAtUtc,
                CreatedAtUtc = r.CreatedAtUtc
            })
            .ToListAsync(ct);

        return new PagedResult<ReportSummaryDto>(items, page, pageSize, total);
    }

}

// Simple DTOs used by the query service. Kept internal to the Reports module for now.
public sealed record ReportSummaryDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? Description { get; init; }
    public DateTimeOffset GeneratedAtUtc { get; init; }
    public DateTimeOffset CreatedAtUtc { get; init; }
}

public sealed record ReportMetricsDTO
{
    public ReportMetricType MetricType { get; set; }
    public ReportPeriodType PeriodType { get; set; }
    public DateOnly? PeriodDate { get; set; }
    public long Value { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public DateTimeOffset UpdatedAtUtc { get; set; }
}


public sealed record TechinicianSummaryDto
{
    public Guid TechnicianUserId { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;
    public string? PhoneNumber { get; init; }
    public DateTimeOffset? LastProfileUpdateAtUtc { get; init; }
}


public sealed record PagedResult<T>
{
    public IEnumerable<T> Items { get; init; } = Enumerable.Empty<T>();
    public int Page { get; init; }
    public int PageSize { get; init; }
    public long Total { get; init; }

    public PagedResult(IEnumerable<T> items, int page, int pageSize, long total)
    {
        Items = items;
        Page = page;
        PageSize = pageSize;
        Total = total;
    }
}
