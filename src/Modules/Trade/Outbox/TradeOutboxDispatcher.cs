using System.Text.Json;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Trade.Data;

namespace TechSupport.Trade.Outbox;

public sealed class TradeOutboxDispatcher(
    IServiceScopeFactory scopeFactory,
    ILogger<TradeOutboxDispatcher> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var dispatched = await DispatchBatchAsync(stoppingToken);
            if (dispatched == 0) await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
        }
    }

    private async Task<int> DispatchBatchAsync(CancellationToken ct)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<TradeDbContext>();
        var publisher = scope.ServiceProvider.GetRequiredService<IPublishEndpoint>();
        var now = DateTimeOffset.UtcNow;
        var messages = await db.OutboxMessages
            .Where(x => x.ProcessedAtUtc == null && (x.NextAttemptAtUtc == null || x.NextAttemptAtUtc <= now))
            .OrderBy(x => x.OccurredAtUtc)
            .Take(20)
            .ToListAsync(ct);

        foreach (var outbox in messages)
        {
            try
            {
                var eventType = Type.GetType(outbox.EventType, throwOnError: true)!;
                var message = JsonSerializer.Deserialize(outbox.Payload, eventType)
                    ?? throw new InvalidOperationException($"Cannot deserialize trade outbox event {outbox.EventType}.");
                await publisher.Publish(message, eventType, ct);
                outbox.ProcessedAtUtc = DateTimeOffset.UtcNow;
                outbox.LastError = null;
            }
            catch (Exception exception) when (exception is not OperationCanceledException)
            {
                outbox.RetryCount++;
                outbox.LastError = exception.Message.Length <= 4000 ? exception.Message : exception.Message[..4000];
                outbox.NextAttemptAtUtc = DateTimeOffset.UtcNow.AddSeconds(
                    Math.Min(300, (int)Math.Pow(2, Math.Min(outbox.RetryCount, 8))));
                logger.LogError(exception, "Trade outbox message {MessageId} could not be published", outbox.MessageId);
            }
        }

        if (messages.Count > 0) await db.SaveChangesAsync(ct);
        return messages.Count;
    }
}
