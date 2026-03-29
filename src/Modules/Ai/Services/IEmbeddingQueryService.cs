using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Ai.Services
{
    public interface IEmbeddingQueryService
    {
        Task<IEnumerable<EmbeddingResult>> QuerySimilarEmbeddingsAsync(string queryText, Guid tenantId);
        
    }
}