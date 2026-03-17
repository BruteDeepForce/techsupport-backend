using MassTransit;
using Microsoft.Extensions.Logging;
using TechSupport.Technician.Contracts.Events;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.Consumers;

public sealed class TechnicianAccountProvisionedConsumer : IConsumer<TechnicianAccountProvisioned>
{
    private readonly ITechnicianService _technicianService;
    private readonly ILogger<TechnicianAccountProvisionedConsumer> _log;

    public TechnicianAccountProvisionedConsumer(ITechnicianService technicianService, ILogger<TechnicianAccountProvisionedConsumer> log)
    {
        _technicianService = technicianService;
        _log = log; 
    }

    public async Task Consume(ConsumeContext<TechnicianAccountProvisioned> context)
    {
        var message = context.Message;
        _log.LogInformation("Received TechnicianAccountProvisioned event for CorrelationId: {CorrelationId}, AppUserId: {AppUserId}, TenantId: {TenantId}, BranchId: {BranchId}, Name: {Name}, Email: {Email}",
            message.CorrelationId, message.AppUserId, message.TenantId, message.BranchId, message.Name, message.Email);
        await _technicianService.CompleteProvisioningAsync(
            message.CorrelationId,
            message.AppUserId,
            message.TenantId,
            message.BranchId,
            message.Name,
            message.Email,
            message.PhoneNumber,
            context.CancellationToken);
    }
}
