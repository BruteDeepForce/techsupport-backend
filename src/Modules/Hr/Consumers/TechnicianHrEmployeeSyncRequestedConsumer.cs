using MassTransit;
using Modules.HR.Application;
using TechSupport.Technician.Contracts.Events;

namespace Modules.HR.Consumers;

public sealed class TechnicianHrEmployeeSyncRequestedConsumer : IConsumer<TechnicianHrEmployeeSyncRequested>
{
    private readonly IEmployeeSyncService _employeeSyncService;

    public TechnicianHrEmployeeSyncRequestedConsumer(IEmployeeSyncService employeeSyncService)
    {
        _employeeSyncService = employeeSyncService;
    }

    public Task Consume(ConsumeContext<TechnicianHrEmployeeSyncRequested> context)
    {
        return _employeeSyncService.SyncTechnicianAsync(context.Message, context.CancellationToken);
    }
}
