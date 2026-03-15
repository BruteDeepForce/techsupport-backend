using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using TechSupport.Customer.Contracts.Events;

namespace TechSupport.Reports.Consumers
{
    public class CustomerCreatedConsumer : IConsumer<CustomerCreated>
    {
        private readonly TechSupport.Reports.Services.IReportService _reportService;

        public CustomerCreatedConsumer(TechSupport.Reports.Services.IReportService reportService)
        {
            _reportService = reportService;
        }

        public async Task Consume(ConsumeContext<CustomerCreated> context)
        {
            var message = context.Message;
            await _reportService.HandleCustomerCreatedAsync(message, context.MessageId, context.CorrelationId, context.CancellationToken);
        }
    }
}