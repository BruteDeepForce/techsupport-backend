using MassTransit;
using TechSupport.Hr.Application;
using TechSupport.Hr.Contracts.Events;

namespace Modules.HR.Consumers;

public sealed class PerformanceUpdateConsumer : IConsumer<PerformanceUpdate>
{
    private readonly IEmployeePerformanceService _employeePerformanceService;

    public PerformanceUpdateConsumer(IEmployeePerformanceService employeePerformanceService)
    {
        _employeePerformanceService = employeePerformanceService;
    }

    public Task Consume(ConsumeContext<PerformanceUpdate> context)
    {
        return ConsumeInternalAsync(context);
    }

    private async Task ConsumeInternalAsync(ConsumeContext<PerformanceUpdate> context)
    {
        var result = await _employeePerformanceService.CreateOrUpdateEmployeePerformanceReportAsync(
            context.Message,
            context.CancellationToken);

        if (!result.Succeeded)
        {
            throw new InvalidOperationException(result.Error ?? "Performance report update failed.");
        }
    }
}
