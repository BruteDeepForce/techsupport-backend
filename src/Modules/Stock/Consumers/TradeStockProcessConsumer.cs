using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.Extensions.Logging;
using TechSupport.Trade.Contracts.Events;

namespace TechSupport.Stock.Consumers
{
    public class TradeStockProcessConsumer : IConsumer<Trade.Contracts.Events.TradeStockProcessEvent>
    {
        private readonly Services.IStockTradeProcessService _stockTradeProcessService;

        private readonly ILogger<TradeStockProcessConsumer> _logger;
        public TradeStockProcessConsumer(Services.IStockTradeProcessService stockTradeProcessService
            , ILogger<TradeStockProcessConsumer> logger)
        
        {
            _logger = logger;
            _stockTradeProcessService = stockTradeProcessService;
        }
        public async Task Consume(ConsumeContext<TradeStockProcessEvent> context)
        {
            var message = context.Message;
            _logger.LogCritical("Received TradeStockProcessEvent for TenantId: {TenantId}, BranchId: {BranchId}, CategoryId: {CategoryId}, DeviceId: {DeviceId}, Name: {Name}, Quantity: {Quantity}, Sku: {Sku}, ImeiOrSerial: {ImeiOrSerial}, Barcode: {Barcode}, UnitPrice: {UnitPrice}, Type: {Type}",
                message.TenantId, message.BranchId, message.CategoryId, message.DeviceId, message.Name, message.Quantity, message.Sku, message.ImeiOrSerial, message.Barcode, message.UnitPrice, message.Type);

            if (message.Type == "Purchase")
            {
                _logger.LogCritical("Processing Buy TradeStockProcessEvent for TenantId: {TenantId}, BranchId: {BranchId}, CategoryId: {CategoryId}, DeviceId: {DeviceId}, Name: {Name}, Quantity: {Quantity}, Sku: {Sku}, ImeiOrSerial: {ImeiOrSerial}, Barcode: {Barcode}, UnitPrice: {UnitPrice}",
                message.TenantId, message.BranchId, message.CategoryId, message.DeviceId, message.Name, message.Quantity, message.Sku, message.ImeiOrSerial, message.Barcode, message.UnitPrice);
            await _stockTradeProcessService.BuyTradeProcessStockTradeAsync(new DTO.StockTradeDTO
            {
                TenantId = message.TenantId,
                BranchId = message.BranchId,
                CategoryId = message.CategoryId,
                DeviceId = message.DeviceId,
                Name = message.Name,
                Quantity = message.Quantity,
                Sku = message.Sku,
                ImeiOrSerial = message.ImeiOrSerial,
                Barcode = message.Barcode,
                UnitPrice = message.UnitPrice
            }, context.CancellationToken);
            }
            else if (message.Type == "Sale")
            {
                await _stockTradeProcessService.SellTradeProcessStockTradeAsync(new DTO.StockTradeDTO
                {
                    TenantId = message.TenantId,
                    BranchId = message.BranchId,
                    CategoryId = message.CategoryId,
                    DeviceId = message.DeviceId,
                    Name = message.Name,
                    Quantity = message.Quantity,
                    Sku = message.Sku,
                    ImeiOrSerial = message.ImeiOrSerial,
                    Barcode = message.Barcode,
                    UnitPrice = message.UnitPrice
                }, context.CancellationToken); 
            }
        }
    }
}