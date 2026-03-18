using System.ComponentModel.DataAnnotations;

namespace TechSupport.Ai.Domain.Entities;

public class EmbeddingRecord
{
    [Key]
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }

    public Guid? BranchId { get; set; }

    public string? SourceModule { get; set; }

    public string Entity { get; set; } = null!; // e.g. "report", "customer", "device"

    public Guid? EntityId { get; set; }

    public string ChunkText { get; set; } = null!;

    // For prototype store embedding as JSON string; later switch to vector type (PGVector)
    public string? EmbeddingJson { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
