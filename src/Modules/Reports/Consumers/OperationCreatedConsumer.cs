using MassTransit;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Reports.Services;

namespace TechSupport.Reports.Consumers;

public sealed class OperationCreatedConsumer : IConsumer<OperationCreated>
{
    private readonly IReportService _reportService;

    public OperationCreatedConsumer(IReportService reportService)
    {
        _reportService = reportService;
    }

    public Task Consume(ConsumeContext<OperationCreated> context)
    {
        return _reportService.HandleOperationCreatedAsync(
            context.Message,
            context.MessageId,
            context.CorrelationId,
            context.CancellationToken);
    }
}
