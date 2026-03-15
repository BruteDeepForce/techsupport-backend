namespace TechSupport.Reports.Services;

public interface ITechnicianReportSetService
{
    Task HandleOperationAssignedToTechnicianAsync(Guid tenantId, Guid? branchId, Guid technicianUserId, DateTimeOffset occurredAtUtc, CancellationToken ct);
}

