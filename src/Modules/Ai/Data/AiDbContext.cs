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

        // Pgvector.Vector must be treated as a scalar (handled by Npgsql pgvector plugin),
        // not discovered as an entity/owned type by EF conventions.
        modelBuilder.Ignore<Pgvector.Vector>();

        modelBuilder.Entity<EmbeddingRecord>(b =>
        {
            b.ToTable("embeddings");     
        });

        base.OnModelCreating(modelBuilder);
    }
}
