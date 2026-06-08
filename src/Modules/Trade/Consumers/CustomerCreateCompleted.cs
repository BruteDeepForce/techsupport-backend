using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Customer.Contracts.Events;
using MassTransit;
using Customer.Contracts.Events;
using TechSupport.Trade.Services;

namespace TechSupport.Trade.Consumers
{
    public class CustomerCreateCompleted : IConsumer<TradeCustomerCreatedComplete>
    {
        private readonly ITradeService tradeService;

        public CustomerCreateCompleted(ITradeService tradeService)
        {
            this.tradeService = tradeService;
        }
        public async Task Consume(ConsumeContext<TradeCustomerCreatedComplete> context)
        {
            var message = context.Message;
            
            await tradeService.StartDeviceCreateWithTradeAsync(
                tenantId: message.TenantId,
                branchId: message.BranchId ?? Guid.Empty,
                tradeId: message.TradeId,
                idempotencyKey: message.TradeCorelationKey,
                customerId: message.CustomerId,
                customerAppUserId: message.AppUserId
            );
        }
    }
}