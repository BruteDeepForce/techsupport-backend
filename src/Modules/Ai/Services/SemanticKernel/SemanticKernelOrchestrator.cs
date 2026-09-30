using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Ai.Domain.Entities;
using Ai.Services.SemanticKernel;
using Ai.Services.SemanticKernel.Tools;
using Microsoft.EntityFrameworkCore;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using TechSupport.Ai.Data;
namespace Ai.Services
{
    public interface ISemanticKernelOrchestrator
    {
        Task<string> GetReply(Guid tenantId, Guid branchId, Guid userId, Guid conversationId, string? input, CancellationToken cancellationToken);
    }

    public class SemanticKernelOrchestrator : ISemanticKernelOrchestrator
    {
        private readonly Kernel _kernel;
        private readonly OperationActionTool _operationActionTool;
        private readonly TechnicianActionTool _technicianActionTool;
        private readonly StockActionTool _stockActionTool;
        private readonly AccountingActionTool _accountingActionTool;
        private readonly CustomerActionTool _customerActionTool;
        private readonly HrActionTool _hrActionTool;
        private readonly AiKernelRequestContext _requestContext;  //! context tenant bazlı olarak injekti bize sağlar

        private readonly AiDbContext _dbContext;


        private readonly IChatCompletionService _chatCompletionService;

        public SemanticKernelOrchestrator(Kernel kernel, OperationActionTool operationActionTool, TechnicianActionTool technicianActionTool, StockActionTool stockActionTool, AccountingActionTool accountingActionTool, CustomerActionTool customerActionTool, HrActionTool hrActionTool, AiDbContext dbContext, AiKernelRequestContext requestContext)
        {
            _kernel = kernel;
            _operationActionTool = operationActionTool;
            _technicianActionTool = technicianActionTool;
            _stockActionTool = stockActionTool;
            _accountingActionTool = accountingActionTool;
            _customerActionTool = customerActionTool;
            _hrActionTool = hrActionTool;
            _dbContext = dbContext;
            _requestContext = requestContext;

            _chatCompletionService = kernel.GetRequiredService<IChatCompletionService>();

            _kernel.Plugins.AddFromObject(_operationActionTool);
            _kernel.Plugins.AddFromObject(_technicianActionTool);
            _kernel.Plugins.AddFromObject(_stockActionTool);
            _kernel.Plugins.AddFromObject(_accountingActionTool);
            _kernel.Plugins.AddFromObject(_customerActionTool);
            _kernel.Plugins.AddFromObject(_hrActionTool);


        }

        public async Task<string> GetReply(Guid tenantId, Guid branchId, Guid userId, Guid conversationId, string? input, CancellationToken cancellationToken)
        {
            if (conversationId == Guid.Empty)
            {
                return "Geçersiz konuşma ID'si.";
            }
            if (tenantId == Guid.Empty)
            {
                return "Geçersiz tenant ID'si.";
            }
            // if (branchId == Guid.Empty).  bypass şuan
            // {
            //     return "Geçersiz branch ID'si.";
            // }
            if (userId == Guid.Empty)
            {
                return "Geçersiz user ID'si.";
            }

            if (string.IsNullOrWhiteSpace(input))
            {
                return "Mesajınız boş olamaz.";
            }

            _requestContext.Set(
                tenantId,
                branchId == Guid.Empty ? null : branchId,
                userId);

            var settings = new OpenAIPromptExecutionSettings
            {
                FunctionChoiceBehavior = FunctionChoiceBehavior.Auto()
            };


            var conversation = await _dbContext.KernelChatHistories
                .FirstOrDefaultAsync(ch => ch.Id == conversationId && ch.TenantId == tenantId && ch.UserId == userId, cancellationToken);

            if (conversation == null)
            {
                conversation = new KernelConversation
                {
                    Id = conversationId,
                    TenantId = tenantId,
                    BranchId = branchId,
                    UserId = userId
                };
                _dbContext.KernelChatHistories.Add(conversation);
            }

            var messages = await _dbContext.ChatMessages
                .AsNoTracking()
                .Where(m => m.ConversationId == conversationId)
                .OrderByDescending(m => m.CreatedAt)
                .Take(20)
                .ToListAsync(cancellationToken);

            messages.Reverse();


            var chatHistory = new ChatHistory();
            chatHistory.AddSystemMessage(KernelOrchestrationConstants.KernelConstant);
            foreach (var message in messages)
            {
                if (message.Role == "User")
                {
                    chatHistory.AddUserMessage(message.Content);
                }
                else
                {
                    chatHistory.AddAssistantMessage(message.Content);
                }
            }
            chatHistory.AddUserMessage(input);


            var response = await _chatCompletionService.GetChatMessageContentAsync(
                chatHistory,
                executionSettings: settings,
                kernel: _kernel
            );

            conversation.ChatMessages.Add(new ChatMessage
            {
                Role = "User",
                Content = input,
                CreatedAt = DateTime.UtcNow
            });
            conversation.ChatMessages.Add(new ChatMessage
            {
                Role = "Assistant",
                Content = response.Content,
                CreatedAt = DateTime.UtcNow
            });

            await _dbContext.SaveChangesAsync(cancellationToken);
            chatHistory.AddAssistantMessage(response.Content);

            return response.Content;
        }
    }
}
