using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TechSupport.Accounting.Contracts.Events;
using TechSupport.Trade.Data;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.SignalR;

namespace TechSupport.Trade.Consumers;

public sealed class TradeAccountingProcessResultedConsumer : IConsumer<TradeAccountingProcessResulted>
{
    private readonly TradeDbContext _db;
    private readonly ITradeStatusHub _tradeStatusHub;

    private readonly ILogger<TradeAccountingProcessResultedConsumer> _logger;   

    public TradeAccountingProcessResultedConsumer(TradeDbContext db, ITradeStatusHub tradeStatusHub, ILogger<TradeAccountingProcessResultedConsumer> logger)
    {
        _db = db;
        _tradeStatusHub = tradeStatusHub;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<TradeAccountingProcessResulted> context)
    {
        var message = context.Message;


        _logger.LogInformation("Processing trade accounting result for TradeId: {TradeId}, TenantId: {TenantId}", message.TradeId, message.TenantId);

        _logger.LogWarning("Received IdempotencyKey: {IdempotencyKey}", message.IdempotencyKey);
        var trade = await _db.Trades.FirstOrDefaultAsync(
            x => x.TenantId == message.TenantId && x.Id == message.TradeId && x.IdempotencyKey == message.IdempotencyKey,
            context.CancellationToken);

        if (trade is null)
            return;

        // Ignore duplicate result events after terminal status is set.
        if (trade.Status == TradeStatus.Completed || trade.Status == TradeStatus.Failed)
            return;

        if (trade.Status != TradeStatus.Pending)
            return;

        if (message.Status == AccountingProcessStatus.Success)
        {
            trade.Status = TradeStatus.Completed;
            trade.CompletedAtUtc = DateTime.UtcNow;
        }
        else
        {
            trade.Status = TradeStatus.Failed;
        }

        await _db.SaveChangesAsync(context.CancellationToken);


        await _tradeStatusHub.SendTradeStatusUpdate(message.TenantId, message.TradeId, trade.Status.ToString());
    }
}
