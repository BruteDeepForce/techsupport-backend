using MassTransit;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Reports.Services;

namespace TechSupport.Reports.Consumers;

public sealed class OperationStatusChangedConsumer : IConsumer<OperationStatusChanged>
{
    private readonly IReportService _reportService;

    public OperationStatusChangedConsumer(IReportService reportService)
    {
        _reportService = reportService;
    }

    public Task Consume(ConsumeContext<OperationStatusChanged> context)
    {
        return _reportService.HandleOperationStatusChangedAsync(
            context.Message,
            context.MessageId,
            context.CorrelationId,
            context.CancellationToken);
    }
}
