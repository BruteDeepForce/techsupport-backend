using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Customer.Contracts.Events;
using TechSupport.Trade.Services;
using Microsoft.Extensions.Logging;

namespace TechSupport.Trade.Consumers
{
    public class CustomerDeviceMapCompletedConsumer : IConsumer<TradeCustomerDeviceMapCompleted>
    {
        private readonly ITradeService tradeService;

        private readonly ILogger<CustomerDeviceMapCompletedConsumer> _logger;
        public CustomerDeviceMapCompletedConsumer(ITradeService tradeService, ILogger<CustomerDeviceMapCompletedConsumer> logger)
        {
            this.tradeService = tradeService;
            _logger = logger;
        }
        public async Task Consume(ConsumeContext<TradeCustomerDeviceMapCompleted> context)
        {
            _logger.LogInformation("Received TradeCustomerDeviceMapCompleted event for TradeId: {TradeId}, CustomerId: {CustomerId}, DeviceId: {DeviceId}", 
                    context.Message.TradeId, context.Message.CustomerId, context.Message.DeviceId);
            await tradeService.AccountModuleInsertAfterMappingAsync(
                tenantId: context.Message.TenantId,
                branchId: context.Message.BranchId,
                customerId: context.Message.CustomerId,
                tradeId: context.Message.TradeId,
                idempotencyKey: context.Message.IdempotencyKey,
                cancellationToken: context.CancellationToken);
            _logger.LogInformation("Completed processing TradeCustomerDeviceMapCompleted event for TradeId: {TradeId}, CustomerId: {CustomerId}, DeviceId: {DeviceId}", 
                    context.Message.TradeId, context.Message.CustomerId, context.Message.DeviceId);
        }
    }
}