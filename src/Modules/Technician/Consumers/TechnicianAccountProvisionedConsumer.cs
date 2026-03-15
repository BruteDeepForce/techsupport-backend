using MassTransit;
using TechSupport.Technician.Contracts.Events;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.Consumers;

public sealed class TechnicianAccountProvisionedConsumer : IConsumer<TechnicianAccountProvisioned>
{
    private readonly ITechnicianService _technicianService;

    public TechnicianAccountProvisionedConsumer(ITechnicianService technicianService)
    {
        _technicianService = technicianService;
    }

    public async Task Consume(ConsumeContext<TechnicianAccountProvisioned> context)
    {
        var message = context.Message;
        await _technicianService.CompleteProvisioningAsync(
            message.CorrelationId,
            message.AppUserId,
            message.TenantId,
            message.BranchId,
            message.FirstName,
            message.LastName,
            message.Email,
            message.PhoneNumber,
            context.CancellationToken);
    }
}
