using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

namespace TechSupport.Ai.Api.Controllers;

[ApiController]
[Route("api/ai")]
public class AiController : ControllerBase
{
    [HttpPost("chat")]
    public IActionResult Chat([FromBody] ChatRequest req)
    {
        // Minimal stub: in the real flow we'll aggregate tenant/customer data,
        // retrieve top-k from vector DB, and call the LLM. For now return placeholder.

        var reply = new ChatResponse
        {
            Text = "(stub) Bu bir örnek yanıttır. AiModule hazır olduğunda gerçek cevap dönecektir.",
            Source = "ai-module-stub"
        };

        return Ok(reply);
    }
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
