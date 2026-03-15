using MassTransit;
using TechSupport.Technician.Contracts.Events;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.Consumers;

public sealed class TechnicianAccountProvisionFailedConsumer : IConsumer<TechnicianAccountProvisionFailed>
{
    private readonly ITechnicianService _technicianService;

    public TechnicianAccountProvisionFailedConsumer(ITechnicianService technicianService)
    {
        _technicianService = technicianService;
    }

    public async Task Consume(ConsumeContext<TechnicianAccountProvisionFailed> context)
    {
        var message = context.Message;
        await _technicianService.FailProvisioningAsync(message.CorrelationId, message.Reason, context.CancellationToken);
    }
}
