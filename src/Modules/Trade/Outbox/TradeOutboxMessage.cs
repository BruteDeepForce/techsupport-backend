using System.Text.Json;

namespace TechSupport.Trade.Outbox;

public sealed class TradeOutboxMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid MessageId { get; set; }
    public Guid CorrelationId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
    public DateTimeOffset OccurredAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? ProcessedAtUtc { get; set; }
    public int RetryCount { get; set; }
    public DateTimeOffset? NextAttemptAtUtc { get; set; }
    public string? LastError { get; set; }

    public static TradeOutboxMessage Create<T>(T message, Guid messageId, Guid correlationId) where T : class => new()
    {
        MessageId = messageId,
        CorrelationId = correlationId,
        EventType = typeof(T).AssemblyQualifiedName
            ?? throw new InvalidOperationException($"Cannot resolve event type {typeof(T).FullName}."),
        Payload = JsonSerializer.Serialize(message)
    };
}

public sealed class TradeInboxMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid MessageId { get; set; }
    public string ConsumerName { get; set; } = string.Empty;
    public DateTimeOffset ProcessedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
