using System.Threading;
using System.Threading.Tasks;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Domain.Enums;

namespace TechSupport.Reports.Services;

public interface IReportQueryService
{
    Task<PagedResult<ReportSummaryDto>> TenantReportSummaryAsync(Guid tenantId, int page = 1, int pageSize = 20, CancellationToken ct = default);
    Task<IReadOnlyCollection<TechinicianSummaryDto>> AllTechnicianSummaryAsync(Guid tenantId, CancellationToken ct = default);
    Task<TechinicianSummaryDto?> SingleTechnicianSummaryAsync(Guid tenantId, Guid technicianUserId, CancellationToken ct = default);
    Task<IReadOnlyCollection<ReportMetricsDTO>> GetAllReportMetricsAsync(Guid tenantId, CancellationToken ct = default);
    // Returns null when no matching metric exists. For ReportPeriodType.AllTime, periodDate is ignored.
    Task<ReportMetricsDTO?> GetReportMetricAsync(Guid tenantId, ReportMetricType metricType, ReportPeriodType periodType, DateOnly? periodDate, CancellationToken ct = default);
}
