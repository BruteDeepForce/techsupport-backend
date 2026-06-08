using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Trade.Contracts.Events;
using MassTransit;
using TechSupport.Device.Services;
namespace TechSupport.Device.Consumers
{
    public class TradeDeviceRegistrationRequestedConsumer : IConsumer<TradeDeviceRegistrationRequested>
    {
        private readonly IDeviceService _deviceService;
        public TradeDeviceRegistrationRequestedConsumer(IDeviceService deviceService)
        {
            _deviceService = deviceService;
        }
        public async Task Consume(ConsumeContext<TradeDeviceRegistrationRequested> context)
        {
            var message = context.Message;

            await _deviceService.RegisterAsync(
                tradeId: message.TradeId,
                tradeCorrelationId: message.IdempotencyKey,
                tenantId: message.TenantId,
                branchId: message.BranchId ?? Guid.Empty,
                brand: message.Brand,
                model: message.Model,
                serialNumber: message.SerialNumber,
                barcodeNumber: message.BarcodeNumber,
                customerName: message.CustomerName,
                status: message.Status,
                problemDescription: message.ProblemDescription,
                warrantyStartAtUtc: message.WarrantyStartAtUtc,
                guaranteePeriod: message.GuaranteePeriod,
                customerId: message.CustomerId,
                appUserId: message.AppUserId,
                ct: context.CancellationToken);
            // Handle the event as needed, e.g., log it or update device registration status

        }
    }
}