namespace TechSupport.Reports.Services;

public interface ITechnicianReportSetService
{
    Task HandleOperationAssignedToTechnicianAsync(Guid tenantId, Guid? branchId, Guid technicianUserId, string description, DateTimeOffset occurredAtUtc, CancellationToken ct);
}

