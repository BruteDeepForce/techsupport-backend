using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using TechSupport.Operation.Services;
using TechSupport.Stock.Contracts.Events;

namespace TechSupport.Operation.Consumers
{
    public class StockReservedConsumer : IConsumer<StockOperationOfferRequested>
    {
        private readonly IOfferService  _offerService;
        public StockReservedConsumer(IOfferService offerService)
        {           
             _offerService = offerService;
        }
        public async Task Consume(ConsumeContext<StockOperationOfferRequested> context)
        {
            var message = context.Message;

            var items = message.Items
                .Select(item => new DTO.OfferItemDTO(
                    item.StockItemId,
                    checked((int)item.Quantity),
                    item.UnitPriceSnapshot))
                .ToList();

            var offer = new DTO.OfferDTO(
                Id: Guid.NewGuid(),
                TenantId: message.TenantId,
                BranchId: message.BranchId,
                OperationId: message.OperationId,
                TechnicianUserId: message.TechnicianUserId,
                CustomerId: null,
                Amount: message.TotalAmount,
                Currency: "TRY",
                CreatedAt: DateTime.UtcNow,
                Items: items);

            await _offerService.TechnicianCreateOfferAsync(offer, context.CancellationToken);
            
            await Task.CompletedTask;
        }
    }
}