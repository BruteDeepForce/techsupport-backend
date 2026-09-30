using Ai.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using TechSupport.Ai.Domain.Entities;

namespace TechSupport.Ai.Data;

public class AiDbContext : DbContext
{
    public AiDbContext(DbContextOptions<AiDbContext> options) : base(options)
    {
    }

    public DbSet<EmbeddingRecord> Embeddings => Set<EmbeddingRecord>();
    public DbSet<KernelConversation> KernelChatHistories => Set<KernelConversation>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("ai");

        // Pgvector.Vector must be treated as a scalar (handled by Npgsql pgvector plugin),
        // not discovered as an entity/owned type by EF conventions.
        modelBuilder.Ignore<Pgvector.Vector>();

        modelBuilder.Entity<EmbeddingRecord>(b =>
        {
            b.ToTable("embeddings");     
        });

        modelBuilder.Entity<KernelConversation>(b =>
        {
            b.ToTable("kernel_chat_histories");
            b.HasMany(k => k.ChatMessages)
             .WithOne(c => c.Conversation)
             .HasForeignKey(c => c.ConversationId);
        });
        
        modelBuilder.Entity<ChatMessage>(b =>
        {
            b.ToTable("chat_messages");

            b.Property(c => c.ConversationId).IsRequired();
        });

        base.OnModelCreating(modelBuilder);
    }
}
