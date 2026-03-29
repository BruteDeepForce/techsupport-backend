using System;

namespace Ai.Services
{
    public class EmbeddingResult
    {
        public Guid Id { get; set; }
        public string ChunkText { get; set; } = null!;
        public double Similarity { get; set; }
        public string? SourceModule { get; set; }
        public string? Entity { get; set; }
        public Guid? EntityId { get; set; }
    }
}
