using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Shared.Integration;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;
using TechSupport.Trade.Contracts.Events;

namespace TechSupport.Stock.Consumers;

public sealed class QuickSaleStockRequestedConsumer(StockDbContext dbContext) : IConsumer<QuickSaleStockRequested>
{
    public async Task Consume(ConsumeContext<QuickSaleStockRequested> context)
    {
        var message = context.Message;
        if (await IsProcessed(message.MessageId, nameof(QuickSaleStockRequestedConsumer), context.CancellationToken)) return;

        await using var transaction = await dbContext.Database.BeginTransactionAsync(context.CancellationToken);
        try
        {
            var pricedItems = new List<QuickSalePricedItem>();
            foreach (var requested in message.Items)
            {
                if (requested.Quantity <= 0) throw new QuickSaleStockException("Satış miktarı sıfırdan büyük olmalıdır.");

                var item = await dbContext.StockItems.AsNoTracking()
                    .SingleOrDefaultAsync(x => x.TenantId == message.TenantId && x.Id == requested.StockItemId, context.CancellationToken)
                    ?? throw new QuickSaleStockException($"Stok ürünü bulunamadı: {requested.StockItemId}");

                if (item.UnitPrice is null or < 0)
                    throw new QuickSaleStockException($"Ürünün geçerli bir satış fiyatı yok: {item.Name}");

                var updated = await dbContext.StockBalances
                    .Where(x => x.TenantId == message.TenantId && x.BranchId == message.BranchId &&
                                x.StockItemId == requested.StockItemId && x.QuantityAvailable >= requested.Quantity)
                    .ExecuteUpdateAsync(setters => setters
                        .SetProperty(x => x.QuantityAvailable, x => x.QuantityAvailable - requested.Quantity), context.CancellationToken);

                if (updated != 1) throw new QuickSaleStockException($"Yetersiz stok: {item.Name}");

                dbContext.StockTransactions.Add(new StockTransaction
                {
                    Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                    StockItemId = item.Id, Quantity = -requested.Quantity, Type = StockTransactionType.QuickSale,
                    ReferenceId = message.QuickSaleId, ReferenceType = "QuickSale", IdempotencyKey = message.IdempotencyKey,
                    Reference = message.QuickSaleId.ToString(), Barcode = item.Barcode
                });

                var lineTotal = item.UnitPrice.Value * requested.Quantity;
                pricedItems.Add(new QuickSalePricedItem(item.Id, item.Name, item.Sku, item.Barcode,
                    requested.Quantity, item.UnitPrice.Value, lineTotal));
            }

            MarkProcessed(message.MessageId, nameof(QuickSaleStockRequestedConsumer));
            var succeeded = new QuickSaleStockSucceeded(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
                message.TenantId, message.BranchId, message.IdempotencyKey, pricedItems, pricedItems.Sum(x => x.LineTotal), DateTimeOffset.UtcNow);
            dbContext.IntegrationOutboxMessages.Add(IntegrationOutboxMessage.Create(succeeded, succeeded.MessageId, succeeded.CorrelationId));
            await dbContext.SaveChangesAsync(context.CancellationToken);
            await transaction.CommitAsync(context.CancellationToken);
        }
        catch (QuickSaleStockException exception)
        {
            await transaction.RollbackAsync(context.CancellationToken);
            dbContext.ChangeTracker.Clear();
            if (await IsProcessed(message.MessageId, nameof(QuickSaleStockRequestedConsumer), context.CancellationToken)) return;
            MarkProcessed(message.MessageId, nameof(QuickSaleStockRequestedConsumer));
            var failed = new QuickSaleStockFailed(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
                message.TenantId, message.BranchId, message.IdempotencyKey, exception.Message, DateTimeOffset.UtcNow);
            dbContext.IntegrationOutboxMessages.Add(IntegrationOutboxMessage.Create(failed, failed.MessageId, failed.CorrelationId));
            await dbContext.SaveChangesAsync(context.CancellationToken);
        }
    }

    private Task<bool> IsProcessed(Guid id, string consumer, CancellationToken ct) =>
        dbContext.ProcessedIntegrationMessages.AnyAsync(x => x.MessageId == id && x.ConsumerName == consumer, ct);

    private void MarkProcessed(Guid id, string consumer) =>
        dbContext.ProcessedIntegrationMessages.Add(new ProcessedIntegrationMessage { MessageId = id, ConsumerName = consumer });
}

public sealed class QuickSaleStockReleaseRequestedConsumer(StockDbContext dbContext) : IConsumer<QuickSaleStockReleaseRequested>
{
    public async Task Consume(ConsumeContext<QuickSaleStockReleaseRequested> context)
    {
        var message = context.Message;
        var consumerName = nameof(QuickSaleStockReleaseRequestedConsumer);
        if (await dbContext.ProcessedIntegrationMessages.AnyAsync(x => x.MessageId == message.MessageId && x.ConsumerName == consumerName, context.CancellationToken)) return;

        await using var transaction = await dbContext.Database.BeginTransactionAsync(context.CancellationToken);
        try
        {
            var consumed = await dbContext.StockTransactions.AsNoTracking()
                .Where(x => x.TenantId == message.TenantId && x.ReferenceId == message.QuickSaleId &&
                            x.ReferenceType == "QuickSale" && x.Type == StockTransactionType.QuickSale)
                .ToListAsync(context.CancellationToken);
            if (consumed.Count == 0) throw new QuickSaleStockException("Kompanzasyon için hızlı satış stok hareketi bulunamadı.");

            foreach (var stockTransaction in consumed)
            {
                var alreadyReleased = await dbContext.StockTransactions.AnyAsync(x => x.TenantId == message.TenantId &&
                    x.ReferenceId == message.QuickSaleId && x.StockItemId == stockTransaction.StockItemId &&
                    x.Type == StockTransactionType.QuickSaleReturn, context.CancellationToken);
                if (alreadyReleased) continue;

                var updated = await dbContext.StockBalances
                    .Where(x => x.TenantId == message.TenantId && x.BranchId == message.BranchId && x.StockItemId == stockTransaction.StockItemId)
                    .ExecuteUpdateAsync(setters => setters.SetProperty(x => x.QuantityAvailable,
                        x => x.QuantityAvailable + -stockTransaction.Quantity), context.CancellationToken);
                if (updated != 1) throw new QuickSaleStockException("Kompanzasyon sırasında stok bakiyesi bulunamadı.");

                dbContext.StockTransactions.Add(new StockTransaction
                {
                    Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                    StockItemId = stockTransaction.StockItemId, Quantity = -stockTransaction.Quantity,
                    Type = StockTransactionType.QuickSaleReturn, ReferenceId = message.QuickSaleId,
                    ReferenceType = "QuickSale", IdempotencyKey = message.IdempotencyKey,
                    Reference = $"Rollback:{message.QuickSaleId}"
                });
            }

            dbContext.ProcessedIntegrationMessages.Add(new ProcessedIntegrationMessage { MessageId = message.MessageId, ConsumerName = consumerName });
            var released = new QuickSaleStockReleased(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
                message.TenantId, message.BranchId, message.IdempotencyKey, DateTimeOffset.UtcNow);
            dbContext.IntegrationOutboxMessages.Add(IntegrationOutboxMessage.Create(released, released.MessageId, released.CorrelationId));
            await dbContext.SaveChangesAsync(context.CancellationToken);
            await transaction.CommitAsync(context.CancellationToken);
        }
        catch (QuickSaleStockException exception)
        {
            await transaction.RollbackAsync(context.CancellationToken);
            dbContext.ChangeTracker.Clear();
            dbContext.ProcessedIntegrationMessages.Add(new ProcessedIntegrationMessage { MessageId = message.MessageId, ConsumerName = consumerName });
            var failed = new QuickSaleStockReleaseFailed(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
                message.TenantId, message.BranchId, message.IdempotencyKey, exception.Message, DateTimeOffset.UtcNow);
            dbContext.IntegrationOutboxMessages.Add(IntegrationOutboxMessage.Create(failed, failed.MessageId, failed.CorrelationId));
            await dbContext.SaveChangesAsync(context.CancellationToken);
        }
    }
}

internal sealed class QuickSaleStockException(string message) : Exception(message);
