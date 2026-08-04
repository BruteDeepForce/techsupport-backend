using System.Text.Json;
using Microsoft.EntityFrameworkCore;

namespace TechSupport.Shared.Integration;

public sealed class IntegrationOutboxMessage
{
    public Guid Id { get; set; }
    public Guid MessageId { get; set; }
    public Guid CorrelationId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
    public DateTimeOffset OccurredAtUtc { get; set; }
    public DateTimeOffset? ProcessedAtUtc { get; set; }
    public int RetryCount { get; set; }
    public DateTimeOffset? NextAttemptAtUtc { get; set; }
    public string? LastError { get; set; }

    public static IntegrationOutboxMessage Create<T>(T message, Guid messageId, Guid correlationId)
        where T : class
    {
        return new IntegrationOutboxMessage
        {
            Id = Guid.NewGuid(),
            MessageId = messageId,
            CorrelationId = correlationId,
            EventType = typeof(T).AssemblyQualifiedName
                ?? throw new InvalidOperationException($"Cannot resolve event type {typeof(T).FullName}."),
            Payload = JsonSerializer.Serialize(message),
            OccurredAtUtc = DateTimeOffset.UtcNow
        };
    }
}

public sealed class ProcessedIntegrationMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid MessageId { get; set; }
    public string ConsumerName { get; set; } = string.Empty;
    public DateTimeOffset ProcessedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}

public interface IIntegrationMessageDbContext
{
    DbSet<IntegrationOutboxMessage> IntegrationOutboxMessages { get; }
    DbSet<ProcessedIntegrationMessage> ProcessedIntegrationMessages { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

public static class IntegrationMessageModelBuilderExtensions
{
    public static void ConfigureIntegrationMessages(this ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<IntegrationOutboxMessage>(b =>
        {
            b.ToTable("outbox_messages");
            b.HasKey(x => x.Id);
            b.Property(x => x.EventType).HasMaxLength(1000).IsRequired();
            b.Property(x => x.Payload).HasColumnType("jsonb").IsRequired();
            b.Property(x => x.LastError).HasMaxLength(4000);
            b.HasIndex(x => x.MessageId).IsUnique();
            b.HasIndex(x => new { x.ProcessedAtUtc, x.NextAttemptAtUtc });
        });

        modelBuilder.Entity<ProcessedIntegrationMessage>(b =>
        {
            b.ToTable("processed_messages");
            b.HasKey(x => x.Id);
            b.Property(x => x.ConsumerName).HasMaxLength(300).IsRequired();
            b.HasIndex(x => new { x.ConsumerName, x.MessageId }).IsUnique();
        });
    }
}
