using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MassTransit;
using TechSupport.Ai.Services;
using TechSupport.Operation.Contracts.Events;

namespace TechSupport.Ai.Consumer
{
    public class OperationCreatedConsumer : IConsumer<OperationCreatedToAI>
    {
        private readonly IOperationCreated _operationCreatedHandler;
        
        public OperationCreatedConsumer(IOperationCreated operationCreatedHandler)
        {
            _operationCreatedHandler = operationCreatedHandler;
        }
        public async Task Consume(ConsumeContext<OperationCreatedToAI> context)
        {
            var message = context.Message;

            await _operationCreatedHandler.HandleOperationCreatedAsync(
                message.CorrelationId,
                message.OperationId,
                message.TenantId,
                message.BranchId,
                message.Title,
                message.Description,
                message.TechnicianInfo,
                message.CustomerInfo,
                message.Status.ToString(),
                message.CreatedAtUtc ?? DateTimeOffset.UtcNow,
                message.EndedAtUtc,
                message.AssignedAtUtc,
                context.CancellationToken);

            await Task.CompletedTask;
        }
    }
}