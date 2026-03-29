using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using TechSupport.Customer.Services;

namespace TechSupport.Customer.Consumers
{
    public class DeviceCustomerMappingConsumer : IConsumer<TechSupport.Device.Contracts.Events.DeviceCustomerMapping>
    {
        private readonly ICustomerService _customerService;
        public DeviceCustomerMappingConsumer(ICustomerService customerService)
        {
            _customerService = customerService;
        }
        public async Task Consume(ConsumeContext<TechSupport.Device.Contracts.Events.DeviceCustomerMapping> context)
        {
            var message = context.Message;

            await _customerService.AssignDeviceToCustomerAsync(
                message.TenantId,
                message.BranchId,
                message.CustomerId,
                message.DeviceId,
                message.SerialNumber,
                message.BarcodeNumber,
                message.ProblemDescription,
                message.Model,
                message.Status,
                context.CancellationToken,
                message.Brand,
                message.IsActive,
                message.GuaranteePeriod,
                message.WarrantyStartAtUtc,
                message.WarrantyEndAtUtc);
        
            // Handle the message here
        }
    }
}
