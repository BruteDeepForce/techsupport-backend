using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Ai.Services;
using MassTransit;
using TechSupport.Operation.Contracts.Events;

namespace TechSupport.Ai.Consumer
{
    public class UpdateOperationStatusConsumer : IConsumer<OperationStatusAIEvent>
    {
        private readonly IOperationStatusChanged _operationStatusChanged;
        public UpdateOperationStatusConsumer(IOperationStatusChanged operationStatusChanged)
        {
            _operationStatusChanged = operationStatusChanged;
        }
        public async Task Consume(ConsumeContext<OperationStatusAIEvent> context)
        {
            var message = context.Message;

                await _operationStatusChanged.HandleOperationStatusChangedAsync(
                    message.CorrelationId,
                    message.OperationId,
                    message.TenantId,
                    message.BranchId,
                    message.CustomerInfo,
                    message.TechnicianInfo,
                    message.Status,
                    message.Title,
                    message.Description,
                    message.CreatedAtUtc,
                    message.AssignedAtUtc,
                    message.EndedAtUtc,
                    context.CancellationToken);
                
                await Task.CompletedTask;
            // Handle the operation status change logic here
        }
    }
}