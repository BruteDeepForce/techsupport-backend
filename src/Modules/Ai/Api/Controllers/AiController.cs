using Ai.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;

namespace TechSupport.Ai.Api.Controllers;

[ApiController]
[Route("api/ai")]
public class AiController : ControllerBase
{
    private readonly IEmbeddingService _embeddingService;
    private readonly IAIOrchestartorService _aiOrchestratorService;

    private readonly IAIResponseFormatter _aiResponseFormatter;

    public AiController(IEmbeddingService embeddingService, IAIOrchestartorService aiOrchestratorService, IAIResponseFormatter aiResponseFormatter)
    {
        _embeddingService = embeddingService;
        _aiOrchestratorService = aiOrchestratorService;
        _aiResponseFormatter = aiResponseFormatter;
    }

    [HttpPost("chat")]
    public async Task<IActionResult> Chat([FromBody] ChatRequest req)
    {
        var reply = await _aiOrchestratorService.ChatAsync(req.Message, req.TenantId);
        return Ok(reply);
    }


    [HttpPost("embedding")]
    public async Task<IActionResult> CreateEmbedding([FromBody] EmbeddingRequest req)
    {
        // In the real flow, this endpoint won't be exposed. Instead, we'll have an event handler for OperationCreated
        // that will call the embedding service directly. This is just for testing the embedding service in isolation.

        var operationCreatedEvent = new TechSupport.Operation.Contracts.Events.OperationCreatedToAI
        {
            OperationId = Guid.NewGuid(),
            TenantId = Guid.NewGuid(),
            BranchId = Guid.Empty,
            Title = req.Title,
            Description = req.Description,
            TechnicianInfo = req.TechnicianInfo,
            CustomerInfo = req.CustomerInfo
        };

        await _embeddingService.GenerateEmbeddingAsync(operationCreatedEvent);

        return Ok(new { Success = true });

    }

    public class EmbeddingRequest
    {
        public string Title { get; set; } = null!;

        [Required]
        public string Description { get; set; } = null!;

        public string? TechnicianInfo { get; set; }

        public string? CustomerInfo { get; set; }
    }


    public class ChatRequest
    {
        [Required]
        public Guid TenantId { get; set; }

        public Guid? CustomerId { get; set; }

        public Guid? DeviceId { get; set; }

        [Required]
        public string Message { get; set; } = null!;
    }

    public class ChatResponse
    {
        public string Text { get; set; } = null!;
        public string? Source { get; set; }
    }
}
