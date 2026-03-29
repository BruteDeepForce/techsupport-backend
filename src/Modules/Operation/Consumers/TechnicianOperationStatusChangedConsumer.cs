using MassTransit;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Operation.Services;
using TechSupport.Technician.Contracts.Events;

namespace TechSupport.Operation.Consumers;

public sealed class TechnicianOperationStatusChangedConsumer : IConsumer<TechnicianOperationStatusChanged>
{
    private readonly IOperationService _operations;
    private readonly IBus _bus;

    public TechnicianOperationStatusChangedConsumer(IOperationService operations, IBus bus)
    {
        _operations = operations;
        _bus = bus;
    }

    public async Task Consume(ConsumeContext<TechnicianOperationStatusChanged> context)
    {
        var msg = context.Message;

        // Fetch current op for old status (so we can publish OperationStatusChanged with old/new).
        var existing = await _operations.GetAsync(msg.TenantId, msg.OperationId, context.CancellationToken);
        var oldStatus = existing?.Status.ToString() ?? string.Empty;

        await _operations.UpdateStatusAsync(msg.TenantId, msg.OperationId, msg.TechnicianUserId, msg.TechnicianInfo, msg.NewStatus, context.CancellationToken);

        //! reports modülüne push
        await _bus.Publish(new OperationStatusChanged(
            msg.OperationId,
            msg.TenantId,
            msg.BranchId,
            oldStatus,
            msg.NewStatus,
            msg.OccurredAtUtc), context.CancellationToken);   //! corelationId nerde ???
        //! ai modülüne push
        await _bus.Publish(new OperationStatusAIEvent
        {
            CorrelationId = Guid.NewGuid(), //! corelationId nerde ???
            OperationId = msg.OperationId,
            TenantId = msg.TenantId,
            BranchId = existing?.BranchId ?? Guid.Empty,
            Title = existing?.Title ?? string.Empty,
            Description = existing?.Description ?? string.Empty,
            TechnicianInfo = msg.TechnicianInfo,
            CustomerInfo = existing?.CustomerId.ToString() ?? string.Empty, //! customer info ekleyelim. operation record a customerId var, onu string olarak yollayalım.
            Status = msg.NewStatus,
            CreatedAtUtc = existing?.CreatedAtUtc,
            AssignedAtUtc = existing?.AssignedAtUtc,
            EndedAtUtc = msg.OccurredAtUtc,
        }, context.CancellationToken);
    }
}
