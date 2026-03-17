using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Reports.Services;

namespace Reports.Consumers
{
    public class TenantCreatedConsumer : IConsumer<TenantCreated>
    {
        private readonly IReportService _reportService;
        
        public TenantCreatedConsumer(IReportService reportService)
        {
            _reportService = reportService;
        }
        public async Task Consume(ConsumeContext<TenantCreated> context)
        {

            await _reportService.HandleTenantCreatedAsync(
                context.Message,
                context.MessageId,
                context.CorrelationId,
                context.CancellationToken); 
        }
    }
}