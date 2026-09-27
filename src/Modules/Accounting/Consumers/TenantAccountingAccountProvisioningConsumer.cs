using MassTransit;
using TechSupport.Accounting.Services;
using TechSupport.Identity.Contracts.Events;

namespace TechSupport.Accounting.Consumers;

public sealed class TenantAccountingAccountProvisioningConsumer : IConsumer<TenantCreated>
{
    private readonly IAccountService _accountService;

    public TenantAccountingAccountProvisioningConsumer(IAccountService accountService)
    {
        _accountService = accountService;
    }

    public async Task Consume(ConsumeContext<TenantCreated> context)
    {
        await _accountService.EnsureDefaultAsync(
            context.Message.TenantId,
            createdBy: "identity.tenant-created",
            ct: context.CancellationToken);
    }
}
