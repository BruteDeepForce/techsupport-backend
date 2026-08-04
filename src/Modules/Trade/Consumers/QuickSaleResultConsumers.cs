using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Trade.Contracts.Events;
using TechSupport.Trade.Data;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.Outbox;

namespace TechSupport.Trade.Consumers;

public sealed class QuickSaleStockSucceededConsumer : IConsumer<QuickSaleStockSucceeded>
{
    private readonly TradeDbContext _db;
    public QuickSaleStockSucceededConsumer(TradeDbContext db) => _db = db;

    public async Task Consume(ConsumeContext<QuickSaleStockSucceeded> context)
    {
        var message = context.Message;
        if (await AlreadyProcessed(message.MessageId, nameof(QuickSaleStockSucceededConsumer), context.CancellationToken)) return;

        await using var tx = await _db.Database.BeginTransactionAsync(context.CancellationToken);
        var sale = await _db.QuickSales.Include(x => x.Items).SingleOrDefaultAsync(
            x => x.Id == message.QuickSaleId && x.TenantId == message.TenantId && x.IdempotencyKey == message.IdempotencyKey,
            context.CancellationToken);
        if (sale is null) throw new InvalidOperationException($"Quick sale {message.QuickSaleId} was not found.");

        if (sale.Status == QuickSaleStatus.StockProcessing)
        {
            var priced = message.Items.ToDictionary(x => x.StockItemId);
            foreach (var item in sale.Items)
            {
                if (!priced.TryGetValue(item.StockItemId, out var snapshot))
                    throw new InvalidOperationException($"Stock response is missing item {item.StockItemId}.");
                item.ProductNameSnapshot = snapshot.ProductName;
                item.SkuSnapshot = snapshot.Sku;
                item.BarcodeSnapshot = snapshot.Barcode;
                item.UnitPriceSnapshot = snapshot.UnitPrice;
                item.LineTotal = snapshot.LineTotal;
            }

            sale.Subtotal = decimal.Round(sale.Items.Sum(x => x.LineTotal), 2, MidpointRounding.AwayFromZero);
            sale.TotalAmount = sale.Subtotal - sale.DiscountAmount;
            sale.PaidAmount = sale.PaidAmount <= 0 ? sale.TotalAmount : sale.PaidAmount;
            sale.UpdatedAtUtc = DateTimeOffset.UtcNow;

            if (sale.DiscountAmount > sale.Subtotal || sale.PaidAmount > sale.TotalAmount)
            {
                sale.Status = QuickSaleStatus.Compensating;
                sale.FailureReason = sale.DiscountAmount > sale.Subtotal
                    ? "Discount amount cannot exceed subtotal."
                    : "Paid amount cannot exceed sale total.";
                AddOutbox(new QuickSaleStockReleaseRequested(
                    Guid.NewGuid(), message.CorrelationId, sale.Id, sale.TenantId, sale.BranchId,
                    sale.IdempotencyKey, sale.FailureReason, DateTimeOffset.UtcNow), message.CorrelationId);
            }
            else
            {
                sale.Status = QuickSaleStatus.AccountingProcessing;
                AddOutbox(new QuickSaleAccountingRequested(
                    Guid.NewGuid(), message.CorrelationId, sale.Id, sale.TenantId, sale.BranchId,
                    sale.IdempotencyKey, sale.SaleNumber, sale.PaymentMethod.ToString(), sale.Subtotal,
                    sale.DiscountAmount, sale.TotalAmount, sale.PaidAmount,
                    message.Items, DateTimeOffset.UtcNow), message.CorrelationId);
            }
        }

        MarkProcessed(message.MessageId, nameof(QuickSaleStockSucceededConsumer));
        await _db.SaveChangesAsync(context.CancellationToken);
        await tx.CommitAsync(context.CancellationToken);
    }

    private void AddOutbox<T>(T message, Guid correlationId) where T : class
    {
        var messageId = (Guid)(typeof(T).GetProperty("MessageId")?.GetValue(message) ?? Guid.NewGuid());
        _db.OutboxMessages.Add(TradeOutboxMessage.Create(message, messageId, correlationId));
    }
    private Task<bool> AlreadyProcessed(Guid messageId, string consumer, CancellationToken ct) =>
        _db.InboxMessages.AnyAsync(x => x.MessageId == messageId && x.ConsumerName == consumer, ct);
    private void MarkProcessed(Guid messageId, string consumer) => _db.InboxMessages.Add(new TradeInboxMessage
        { Id = Guid.NewGuid(), MessageId = messageId, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
}

public sealed class QuickSaleStockFailedConsumer : IConsumer<QuickSaleStockFailed>
{
    private readonly TradeDbContext _db;
    public QuickSaleStockFailedConsumer(TradeDbContext db) => _db = db;
    public async Task Consume(ConsumeContext<QuickSaleStockFailed> context)
    {
        var m = context.Message;
        var consumer = nameof(QuickSaleStockFailedConsumer);
        if (await _db.InboxMessages.AnyAsync(x => x.MessageId == m.MessageId && x.ConsumerName == consumer, context.CancellationToken)) return;
        var sale = await _db.QuickSales.SingleOrDefaultAsync(x => x.Id == m.QuickSaleId && x.TenantId == m.TenantId, context.CancellationToken);
        if (sale is null) throw new InvalidOperationException($"Quick sale {m.QuickSaleId} was not found.");
        if (sale.Status == QuickSaleStatus.StockProcessing)
        {
            sale.Status = QuickSaleStatus.Failed;
            sale.FailureReason = m.Reason;
            sale.FailedAtUtc = DateTimeOffset.UtcNow;
        }
        Mark(m.MessageId, consumer);
        await _db.SaveChangesAsync(context.CancellationToken);
    }
    private void Mark(Guid id, string consumer) => _db.InboxMessages.Add(new TradeInboxMessage { Id = Guid.NewGuid(), MessageId = id, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
}

public sealed class QuickSaleAccountingSucceededConsumer : IConsumer<QuickSaleAccountingSucceeded>
{
    private readonly TradeDbContext _db;
    public QuickSaleAccountingSucceededConsumer(TradeDbContext db) => _db = db;
    public async Task Consume(ConsumeContext<QuickSaleAccountingSucceeded> context)
    {
        var m = context.Message;
        var consumer = nameof(QuickSaleAccountingSucceededConsumer);
        if (await Seen(m.MessageId, consumer, context.CancellationToken)) return;
        var sale = await _db.QuickSales.SingleOrDefaultAsync(x => x.Id == m.QuickSaleId && x.TenantId == m.TenantId, context.CancellationToken)
            ?? throw new InvalidOperationException($"Quick sale {m.QuickSaleId} was not found.");
        if (sale.Status == QuickSaleStatus.AccountingProcessing)
        {
            sale.Status = QuickSaleStatus.Completed;
            sale.AccountingInvoiceId = m.InvoiceId;
            sale.AccountingPaymentId = m.PaymentId;
            sale.CompletedAtUtc = DateTimeOffset.UtcNow;
            sale.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }
        Mark(m.MessageId, consumer);
        await _db.SaveChangesAsync(context.CancellationToken);
    }
    private Task<bool> Seen(Guid id, string consumer, CancellationToken ct) => _db.InboxMessages.AnyAsync(x => x.MessageId == id && x.ConsumerName == consumer, ct);
    private void Mark(Guid id, string consumer) => _db.InboxMessages.Add(new TradeInboxMessage { Id = Guid.NewGuid(), MessageId = id, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
}

public sealed class QuickSaleAccountingFailedConsumer : IConsumer<QuickSaleAccountingFailed>
{
    private readonly TradeDbContext _db;
    public QuickSaleAccountingFailedConsumer(TradeDbContext db) => _db = db;
    public async Task Consume(ConsumeContext<QuickSaleAccountingFailed> context)
    {
        var m = context.Message;
        var consumer = nameof(QuickSaleAccountingFailedConsumer);
        if (await _db.InboxMessages.AnyAsync(x => x.MessageId == m.MessageId && x.ConsumerName == consumer, context.CancellationToken)) return;
        var sale = await _db.QuickSales.SingleOrDefaultAsync(x => x.Id == m.QuickSaleId && x.TenantId == m.TenantId, context.CancellationToken)
            ?? throw new InvalidOperationException($"Quick sale {m.QuickSaleId} was not found.");
        if (sale.Status == QuickSaleStatus.AccountingProcessing)
        {
            sale.Status = QuickSaleStatus.Compensating;
            sale.FailureReason = m.Reason;
            sale.FailedAtUtc = DateTimeOffset.UtcNow;
            var eventId = Guid.NewGuid();
            var release = new QuickSaleStockReleaseRequested(eventId, m.CorrelationId, sale.Id, sale.TenantId,
                sale.BranchId, sale.IdempotencyKey, m.Reason, DateTimeOffset.UtcNow);
            _db.OutboxMessages.Add(TradeOutboxMessage.Create(release, eventId, m.CorrelationId));
        }
        Mark(m.MessageId, consumer);
        await _db.SaveChangesAsync(context.CancellationToken);
    }
    private void Mark(Guid id, string consumer) => _db.InboxMessages.Add(new TradeInboxMessage { Id = Guid.NewGuid(), MessageId = id, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
}

public sealed class QuickSaleStockReleasedConsumer : IConsumer<QuickSaleStockReleased>
{
    private readonly TradeDbContext _db;
    public QuickSaleStockReleasedConsumer(TradeDbContext db) => _db = db;
    public async Task Consume(ConsumeContext<QuickSaleStockReleased> context)
    {
        var m = context.Message;
        var consumer = nameof(QuickSaleStockReleasedConsumer);
        if (await _db.InboxMessages.AnyAsync(x => x.MessageId == m.MessageId && x.ConsumerName == consumer, context.CancellationToken)) return;
        var sale = await _db.QuickSales.SingleOrDefaultAsync(x => x.Id == m.QuickSaleId && x.TenantId == m.TenantId, context.CancellationToken)
            ?? throw new InvalidOperationException($"Quick sale {m.QuickSaleId} was not found.");
        if (sale.Status == QuickSaleStatus.Compensating)
        {
            sale.Status = QuickSaleStatus.Compensated;
            sale.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }
        Mark(m.MessageId, consumer);
        await _db.SaveChangesAsync(context.CancellationToken);
    }
    private void Mark(Guid id, string consumer) => _db.InboxMessages.Add(new TradeInboxMessage { Id = Guid.NewGuid(), MessageId = id, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
}

public sealed class QuickSaleStockReleaseFailedConsumer : IConsumer<QuickSaleStockReleaseFailed>
{
    private readonly TradeDbContext _db;
    public QuickSaleStockReleaseFailedConsumer(TradeDbContext db) => _db = db;
    public async Task Consume(ConsumeContext<QuickSaleStockReleaseFailed> context)
    {
        var m = context.Message;
        var consumer = nameof(QuickSaleStockReleaseFailedConsumer);
        if (await _db.InboxMessages.AnyAsync(x => x.MessageId == m.MessageId && x.ConsumerName == consumer, context.CancellationToken)) return;
        var sale = await _db.QuickSales.SingleOrDefaultAsync(x => x.Id == m.QuickSaleId && x.TenantId == m.TenantId, context.CancellationToken)
            ?? throw new InvalidOperationException($"Quick sale {m.QuickSaleId} was not found.");
        sale.Status = QuickSaleStatus.CompensationFailed;
        sale.FailureReason = $"{sale.FailureReason} Stock compensation failed: {m.Reason}";
        sale.UpdatedAtUtc = DateTimeOffset.UtcNow;
        _db.InboxMessages.Add(new TradeInboxMessage { Id = Guid.NewGuid(), MessageId = m.MessageId, ConsumerName = consumer, ProcessedAtUtc = DateTimeOffset.UtcNow });
        await _db.SaveChangesAsync(context.CancellationToken);
    }
}
