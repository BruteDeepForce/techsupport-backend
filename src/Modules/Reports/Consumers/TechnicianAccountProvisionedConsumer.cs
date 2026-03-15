using MassTransit;
using TechSupport.Reports.Services;
using TechSupport.Technician.Contracts.Events;

namespace TechSupport.Reports.Consumers;

public sealed class TechnicianAccountProvisionedConsumer : IConsumer<TechnicianAccountProvisioned>
{
    private readonly IReportService _reportService;

    public TechnicianAccountProvisionedConsumer(IReportService reportService)
    {
        _reportService = reportService;
    }

    public Task Consume(ConsumeContext<TechnicianAccountProvisioned> context)
    {
        // Treat the snapshot update as part of reporting projections.
        // We still pass message ids for idempotency to avoid repeats.
        return _reportService.HandleTechnicianAccountProvisionedAsync(
            context.Message,
            context.MessageId,
            context.CorrelationId,
            context.CancellationToken);
    }
}
