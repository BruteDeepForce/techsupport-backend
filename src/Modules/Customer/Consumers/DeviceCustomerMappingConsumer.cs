using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.Extensions.Logging;
using TechSupport.Customer.Services;

namespace TechSupport.Customer.Consumers
{
    public class DeviceCustomerMappingConsumer : IConsumer<TechSupport.Device.Contracts.Events.DeviceCustomerMapping>
    {
        private readonly ICustomerService _customerService;
        private readonly ILogger<DeviceCustomerMappingConsumer> _logger;
        public DeviceCustomerMappingConsumer(ICustomerService customerService, ILogger<DeviceCustomerMappingConsumer> logger)
        {
            _customerService = customerService;
            _logger = logger;
        }
        public async Task Consume(ConsumeContext<TechSupport.Device.Contracts.Events.DeviceCustomerMapping> context)
        {
            var message = context.Message;
            _logger.LogWarning("Received DeviceCustomerMapping event for CustomerId: {CustomerId}, DeviceId: {DeviceId}", 
                    message.CustomerId, message.DeviceId);
    

             var result = await _customerService.AssignDeviceToCustomerAsync(
                message.TenantId,
                message.BranchId,
                message.CustomerId,
                message.AppUserId,
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
                message.WarrantyEndAtUtc,
                message.TradeId,
                message.IdempotencyKey);

            if (!result)         {
                _logger.LogError("Failed to assign DeviceId: {DeviceId} to CustomerId: {CustomerId}", 
                    message.DeviceId, message.CustomerId);
            }
            else
            {
                _logger.LogWarning("Successfully assigned DeviceId: {DeviceId} to CustomerId: {CustomerId}", 
                    message.DeviceId, message.CustomerId);
            }
            // Handle the message here
        }
    }
}
