using MassTransit;
using TechSupport.Customer.Services;
using TechSupport.Identity.Contracts.Events;

namespace TechSupport.Customer.Consumers;

public sealed class CustomerAccountProvisionedConsumer : IConsumer<CustomerAccountProvisioned>
{
    private readonly ICustomerService _customerService;

    public CustomerAccountProvisionedConsumer(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    public async Task Consume(ConsumeContext<CustomerAccountProvisioned> context)
    {
        var message = context.Message;
        await _customerService.CompleteProvisioningAsync(
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