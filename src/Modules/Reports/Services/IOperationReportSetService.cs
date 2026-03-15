using TechSupport.Operation.Contracts.Events;

namespace TechSupport.Reports.Services;

public interface IOperationReportSetService
{
    Task HandleOperationCreatedAsync(OperationCreated message, CancellationToken ct);

    Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct);
    Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct);
    Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, CancellationToken ct);
}
