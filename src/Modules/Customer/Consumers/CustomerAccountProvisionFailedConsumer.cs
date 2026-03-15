using MassTransit;
using TechSupport.Customer.Services;
using TechSupport.Identity.Contracts.Events;

namespace TechSupport.Customer.Consumers;

public sealed class CustomerAccountProvisionFailedConsumer : IConsumer<CustomerAccountProvisionFailed>
{
    private readonly ICustomerService _customerService;

    public CustomerAccountProvisionFailedConsumer(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    public async Task Consume(ConsumeContext<CustomerAccountProvisionFailed> context)
    {
        var message = context.Message;
        await _customerService.FailProvisioningAsync(message.CorrelationId, message.Reason, context.CancellationToken);
    }
}