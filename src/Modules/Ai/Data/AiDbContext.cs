using Microsoft.EntityFrameworkCore;
using TechSupport.Ai.Domain.Entities;

namespace TechSupport.Ai.Data;

public class AiDbContext : DbContext
{
    public AiDbContext(DbContextOptions<AiDbContext> options) : base(options)
    {
    }

    public DbSet<EmbeddingRecord> Embeddings => Set<EmbeddingRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("ai");

        modelBuilder.Entity<EmbeddingRecord>(b =>
        {
            b.ToTable("embeddings");
            b.HasKey(x => x.Id);
            b.Property(x => x.ChunkText).HasMaxLength(4000);
            b.HasIndex(x => new { x.TenantId, x.Entity, x.EntityId });
        });

        base.OnModelCreating(modelBuilder);
    }
}
