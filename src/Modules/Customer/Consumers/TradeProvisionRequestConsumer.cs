using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Trade.Contracts.Events;
using MassTransit;
using TechSupport.Customer.Services;
using Microsoft.VisualBasic;
namespace TechSupport.Customer.Consumers
{
    public class TradeProvisionRequestConsumer : IConsumer<TradeCustomerProvisionRequested>
    {
        private readonly ICustomerService _customerService;
        public TradeProvisionRequestConsumer(ICustomerService customerService)        {
            _customerService = customerService;
        }
        public Task Consume(ConsumeContext<TradeCustomerProvisionRequested> context)
        {
            var message = context.Message;
            return _customerService.StartProvisioningAsync(
                tenantId: message.TenantId,
                branchId: message.BranchId,
                name: message.Name,
                email: message.Email,
                phoneNumber: message.PhoneNumber,
                temporaryPassword: message.TemporaryPassword,
                tradeID : message.TradeId,
                TradeCorelationId : message.IdempotencyKey,
                ct: context.CancellationToken);
        }
    }
}