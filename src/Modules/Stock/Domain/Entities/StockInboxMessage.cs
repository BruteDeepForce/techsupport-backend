using System.Text.Json;

namespace TechSupport.Stock.Domain.Entities;

public sealed class StockInboxMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid MessageId { get; set; }
    public string ConsumerName { get; set; } = string.Empty;
    public string ResponseType { get; set; } = string.Empty;
    public string ResponsePayload { get; set; } = string.Empty;
    public DateTimeOffset ProcessedAtUtc { get; set; } = DateTimeOffset.UtcNow;

    public static StockInboxMessage Create<T>(Guid messageId, string consumerName, T response) where T : class => new()
    {
        MessageId = messageId,
        ConsumerName = consumerName,
        ResponseType = typeof(T).AssemblyQualifiedName
            ?? throw new InvalidOperationException($"Cannot resolve response type {typeof(T).FullName}."),
        ResponsePayload = JsonSerializer.Serialize(response)
    };

    public (object Response, Type Type) DeserializeResponse()
    {
        var type = Type.GetType(ResponseType, throwOnError: true)!;
        return (JsonSerializer.Deserialize(ResponsePayload, type)
                ?? throw new InvalidOperationException($"Cannot deserialize stock inbox response {ResponseType}."), type);
    }
}
