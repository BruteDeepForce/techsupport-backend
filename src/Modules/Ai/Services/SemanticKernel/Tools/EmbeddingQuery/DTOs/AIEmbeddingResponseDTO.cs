using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ai.Services.SemanticKernel.Tools.EmbeddingQuery.DTOs
{
    public class AIEmbeddingResponseDTO
    {
    public Guid DocumentId { get; set; }

    public string DocumentName { get; set; } = null!;

    public string? SectionTitle { get; set; }

    public int ChunkIndex { get; set; }

    public string ChunkText { get; set; } = null!;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAtUtc { get; set; }
        
    }
}