using System.ComponentModel.DataAnnotations.Schema;

namespace TechSupport.Ai.Domain.Entities;

public class PolicyEmbeddingChunk
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }

    public Guid? BranchId { get; set; }

    public Guid DocumentId { get; set; }

    public string DocumentName { get; set; } = null!;

    public string? SectionTitle { get; set; }

    public int ChunkIndex { get; set; }

    public string ChunkText { get; set; } = null!;

    [Column(TypeName = "vector(3072)")]
    public Pgvector.Vector? Embedding { get; set; }

    public string EmbeddingModel { get; set; } = null!;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAtUtc { get; set; }
}
