using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Numerics;


namespace TechSupport.Ai.Domain.Entities;

public class EmbeddingRecord
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }

    public Guid? BranchId { get; set; }

    public string? SourceModule { get; set; }

    public string Entity { get; set; } = null!; // e.g. "report", "customer", "device"

    public Guid? EntityId { get; set; }

//!burada chunktext embeddinge vektörleniyor. vektörel sorgulama ile yakın chunktext bilgisine başvuruluyor.
    public string ChunkText { get; set; } = null!;

    [Column(TypeName = "vector(3072)")]
    public Pgvector.Vector? Embedding { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
