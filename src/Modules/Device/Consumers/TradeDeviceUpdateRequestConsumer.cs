using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Customer.Contracts.Events;
using MassTransit;
using TechSupport.Device.Services;

namespace TechSupport.Device.Consumers
{
    public class TradeDeviceUpdateRequestConsumer : IConsumer<TradeDeviceUpdateRequest>
    {
        private readonly IDeviceService _deviceService;
        public TradeDeviceUpdateRequestConsumer(IDeviceService deviceService)
        {
            _deviceService = deviceService;
        }
        public async Task Consume(ConsumeContext<TradeDeviceUpdateRequest> context)
        {
            var message = context.Message;

            var result = await _deviceService.UpdateDeviceAsync(message, context.CancellationToken);

        }
    }
}