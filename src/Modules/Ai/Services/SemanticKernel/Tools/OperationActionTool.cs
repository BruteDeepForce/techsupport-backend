using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using TechSupport.Operation.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class OperationActionTool
    {
        private readonly IOperationQueryToAI _operationQueryToAI;
        private readonly ISetActionFromAI _setAction;

        private readonly AiKernelRequestContext _requestContext;
        

        private readonly ILogger<OperationActionTool> _logger;

        public OperationActionTool(IOperationQueryToAI operationQueryToAI, ISetActionFromAI setAction, AiKernelRequestContext requestContext, ILogger<OperationActionTool> logger)
        {
            _operationQueryToAI = operationQueryToAI;
            _setAction = setAction;
            _requestContext = requestContext;
            _logger = logger;
        }
        [KernelFunction("Get-Operations")]
        [Description("Get all operations, optionally within a specific date range")]
        public async Task<IReadOnlyCollection<ResponseOperation>> CheckAllOperations(DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize)
        {
            var tenantId = _requestContext.TenantId;
            var branchId = _requestContext.BranchId ?? Guid.Empty;

            var operations = await _operationQueryToAI.CheckAllOperations(tenantId, branchId, From?.UtcDateTime, To?.UtcDateTime, page, pageSize);
            // Implementation for checking all operations
            return operations;
        }
        [KernelFunction("Get-Tickets")]
        [Description("Get all tickets, optionally within a specific date range. You can see the details of each ticket including its status and creation date. Acılan ticket işleme alınmış mı görebilirsin")]
        public async Task<IReadOnlyCollection<ResponseTicket>> CheckAllTickets(DateTimeOffset? From, DateTimeOffset? To, int page, int pageSize)
        {
            var tenantId = _requestContext.TenantId;
            var branchId = _requestContext.BranchId ?? Guid.Empty;

            var tickets = await _operationQueryToAI.CheckAllTickets(tenantId, branchId, From?.UtcDateTime, To?.UtcDateTime, page, pageSize);
            // Implementation for checking all tickets
            return tickets;
        }

        [KernelFunction("Set-Ticket-To-Operation")]
        [Description("You can assign a ticket to a technician and start the operation")]
        public async Task<ResponseOperation> SetTicketToOperation(Guid ticketId, Guid adminUserId, 
            Guid technicianUserId, string technicianName, OpPriority priority, OpType type, CancellationToken cancellationToken)
        {
            var tenantId = _requestContext.TenantId;
            var result = await _setAction.SetTicketToOperation(tenantId, ticketId, adminUserId, technicianUserId, technicianName, priority, type, cancellationToken);

            _logger.LogInformation("SetTicketToOperation result: {Result}", result);

            return result;
        }
    }
}