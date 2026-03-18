using MassTransit;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.Consumers;

public sealed class OperationAssignedToTechnicianConsumer : IConsumer<OperationAssignedToTechnician>
{
    private readonly ITechnicianService _technicianService;

    public OperationAssignedToTechnicianConsumer(ITechnicianService technicianService)
    {
        _technicianService = technicianService;
    }

    public async Task Consume(ConsumeContext<OperationAssignedToTechnician> context)
    {
        var message = context.Message;
        var ct = context.CancellationToken;

        // Create a work item in the Technician module's database so assignment/acceptance
        // is handled inside the Technician module.

        await _technicianService.OperationAssignAsync(
            message.TenantId,
            message.OperationId,
            message.BranchId,
            message.TechnicianUserId,
            message.CustomerId,
            message.DeviceId,
                message.Title,
                message.Description,
                message.OccurredAtUtc,
            ct);
    }
}
