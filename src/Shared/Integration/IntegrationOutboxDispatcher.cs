using System.Text.Json;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace TechSupport.Shared.Integration;

public sealed class IntegrationOutboxDispatcher<TDbContext> : BackgroundService
    where TDbContext : DbContext, IIntegrationMessageDbContext
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<IntegrationOutboxDispatcher<TDbContext>> _logger;

    public IntegrationOutboxDispatcher(
        IServiceScopeFactory scopeFactory,
        ILogger<IntegrationOutboxDispatcher<TDbContext>> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var dispatched = await DispatchBatchAsync(stoppingToken);
            if (dispatched == 0)
                await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
        }
    }

    private async Task<int> DispatchBatchAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<TDbContext>();
        var publisher = scope.ServiceProvider.GetRequiredService<IPublishEndpoint>();
        var now = DateTimeOffset.UtcNow;

        var messages = await db.IntegrationOutboxMessages
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
                    ?? throw new InvalidOperationException($"Could not deserialize outbox event {outbox.EventType}.");

                await publisher.Publish(message, eventType, ct);
                outbox.ProcessedAtUtc = DateTimeOffset.UtcNow;
                outbox.LastError = null;
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                outbox.RetryCount++;
                outbox.LastError = ex.Message.Length <= 4000 ? ex.Message : ex.Message[..4000];
                var delaySeconds = Math.Min(300, (int)Math.Pow(2, Math.Min(outbox.RetryCount, 8)));
                outbox.NextAttemptAtUtc = DateTimeOffset.UtcNow.AddSeconds(delaySeconds);
                _logger.LogError(ex, "Failed to dispatch outbox message {MessageId} from {DbContext}",
                    outbox.MessageId, typeof(TDbContext).Name);
            }
        }

        if (messages.Count > 0)
            await db.SaveChangesAsync(ct);

        return messages.Count;
    }
}
