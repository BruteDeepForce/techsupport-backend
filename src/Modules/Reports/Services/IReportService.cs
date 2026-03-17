using TechSupport.Customer.Contracts.Events;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Technician.Contracts.Events;

namespace TechSupport.Reports.Services;

public interface IReportService
{
    Task HandleCustomerCreatedAsync(CustomerCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task HandleOperationCreatedAsync(OperationCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task HandleTenantCreatedAsync(TenantCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct);

    Task HandleOperationAssignedToTechnicianAsync(OperationAssignedToTechnician message, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task HandleOperationStatusChangedAsync(OperationStatusChanged message, Guid? messageId, Guid? correlationId, CancellationToken ct);

    Task HandleTechnicianAccountProvisionedAsync(TechnicianAccountProvisioned message, Guid? messageId, Guid? correlationId, CancellationToken ct);

    Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
}