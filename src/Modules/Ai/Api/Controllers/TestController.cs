using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Ai.Services.SemanticKernel;
using Ai.Services.SemanticKernel.Tools.Embedding;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Ai.Api.Controllers
{
    [ApiController]
    [Route("api/ai/[controller]")]
    public class TestController : ControllerBase
    {
        private readonly ILogger<TestController> _logger;
        private readonly EmbeddingQueryTool _embeddingQueryTool;

        private readonly AiKernelRequestContext _aiKernelRequestContext;

        public TestController(ILogger<TestController> logger, EmbeddingQueryTool embeddingQueryTool, AiKernelRequestContext aiKernelRequestContext)
        {
            _logger = logger;
            _embeddingQueryTool = embeddingQueryTool;
            _aiKernelRequestContext = aiKernelRequestContext;
        }

        [HttpPost("query-test")]
        public async Task<IActionResult> QueryEmbedding([FromQuery] string query, [FromQuery] int topK = 5)
        {
            var tenantId = User.FindFirstValue("tenant_id");
            Guid.TryParse(tenantId, out var tenantGuid);
            var branchId = User.FindFirstValue("branch_id");
            Guid.TryParse(branchId, out var branchGuid);
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            Guid.TryParse(userId, out var userGuid);

            _aiKernelRequestContext.Set(tenantGuid, branchGuid == Guid.Empty ? null : branchGuid, userGuid);

            var role = User.FindFirstValue(ClaimTypes.Role);

            if (role != "admin")
            {
                return Unauthorized("You must be an Admin to access this endpoint.");
            }

            var result = await _embeddingQueryTool.QueryEmbeddingAsync(query, topK);
            _logger.LogInformation("QueryEmbedding called with query: {Query} and topK: {TopK}", query, topK);

            _logger.LogInformation("QueryEmbedding result: {Result}", result.ToString());
            return Ok(result);
        }

    }
}