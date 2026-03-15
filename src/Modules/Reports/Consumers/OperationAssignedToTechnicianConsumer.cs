using MassTransit;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Reports.Services;

namespace TechSupport.Reports.Consumers;

public sealed class OperationAssignedToTechnicianConsumer : IConsumer<OperationAssignedToTechnician>
{
    private readonly IReportService _reportService;

    public OperationAssignedToTechnicianConsumer(IReportService reportService)
    {
        _reportService = reportService;
    }

    public Task Consume(ConsumeContext<OperationAssignedToTechnician> context)
    {
        return _reportService.HandleOperationAssignedToTechnicianAsync(
            context.Message,
            context.MessageId,
            context.CorrelationId,
            context.CancellationToken);
    }
}
