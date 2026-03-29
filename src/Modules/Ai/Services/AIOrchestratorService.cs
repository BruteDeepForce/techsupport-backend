using Microsoft.Extensions.Logging;
using OpenAI.Chat;

namespace Ai.Services
{
    public class AIOrchestratorService : IAIOrchestartorService
    {
        private readonly IEmbeddingQueryService _embeddingQueryService;
        private readonly ChatClient _chatClient;
        private readonly ILogger<AIOrchestratorService> _logger;

        private readonly IAIResponseFormatter _responseFormatter;

        public AIOrchestratorService(
            IEmbeddingQueryService embeddingQueryService, 
            ChatClient chatClient,
            ILogger<AIOrchestratorService> logger,
            IAIResponseFormatter responseFormatter)
        {
            _embeddingQueryService = embeddingQueryService;
            _chatClient = chatClient;
            _logger = logger;
            _responseFormatter = responseFormatter;
        }

        public async Task<string> ChatAsync(string query, Guid tenantId)
        {
            try
            {
                _logger.LogInformation("Starting ChatAsync for query: {Query}, TenantId: {TenantId}", query, tenantId);

                //!! 1. Semantic Search: gelen qyuerye göre embedding oluşturup benzer embeddingleri bulacağız
                var similarRecords = await _embeddingQueryService.QuerySimilarEmbeddingsAsync(query, tenantId);
                
                //! 2. Format Context: ---- şeklinde tüm chunkları birleştirdik
                var context = string.Join("\n---\n", similarRecords.Select(r => r.ChunkText));

                if (string.IsNullOrWhiteSpace(context))
                {
                    _logger.LogWarning("No relevant context found for query: {Query}", query);
                    context = "No relevant technical support information found in the database.";
                }

                var reply = await _responseFormatter.FormatResponseAsync(query, context);

                return reply;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred in ChatAsync for query: {Query}", query);
                return "An error occurred while processing your request.";
            }
        }
    }
}