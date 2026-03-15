using TechSupport.Customer.Contracts.Events;
using TechSupport.Operation.Contracts.Events;

namespace TechSupport.Reports.Services;

public interface IReportService
{
    Task HandleCustomerCreatedAsync(CustomerCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task HandleOperationCreatedAsync(OperationCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
    Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct);
}