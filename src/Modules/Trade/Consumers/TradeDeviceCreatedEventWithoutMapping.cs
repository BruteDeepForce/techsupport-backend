using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.Extensions.Logging;
using TechSupport.Trade.Services;

namespace TechSupport.Trade.Consumers
{
    public class TradeDeviceCreatedEventWithoutMapping : IConsumer<TechSupport.Device.Contracts.Events.TradeDeviceCreatedEvent>
    {
        private readonly ITradeService tradeService;

        private readonly ILogger<TradeDeviceCreatedEventWithoutMapping> _logger;
        public TradeDeviceCreatedEventWithoutMapping(ITradeService tradeService, ILogger<TradeDeviceCreatedEventWithoutMapping> logger)
        {
            this.tradeService = tradeService;
            _logger = logger;
        }
        public async Task Consume(ConsumeContext<TechSupport.Device.Contracts.Events.TradeDeviceCreatedEvent> context)
        {
            _logger.LogWarning("Received TradeDeviceCreatedEvent event for TradeId: {TradeId}, CustomerId: {CustomerId}, DeviceId: {DeviceId}",
                    context.Message.TradeId, context.Message.CustomerId, context.Message.DeviceId);
            await tradeService.AccountModuleInsertAfterMappingAsync(
                tenantId: context.Message.TenantId,
                branchId: context.Message.BranchId,
                customerId: context.Message.CustomerId,
                tradeId: context.Message.TradeId,
                idempotencyKey: context.Message.IdempotencyKey,
                cancellationToken: context.CancellationToken);
            _logger.LogWarning("Completed processing TradeDeviceCreatedEvent event for TradeId: {TradeId}, CustomerId: {CustomerId}, DeviceId: {DeviceId}",
                    context.Message.TradeId, context.Message.CustomerId, context.Message.DeviceId);
        }
    }
}