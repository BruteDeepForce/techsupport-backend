using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.SemanticKernel;
using Ai.Services.SemanticKernel;
using TechSupport.Technician.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class TechnicianActionTool
    {
        private readonly IQueryTechnician _technicianQueryToAI;
        private readonly AiKernelRequestContext _requestContext;

        public TechnicianActionTool(IQueryTechnician technicianQueryToAI, AiKernelRequestContext requestContext)
        {
            _technicianQueryToAI = technicianQueryToAI;
            _requestContext = requestContext;
        }
        [KernelFunction("Get-Technicians")]
        [Description("Get all technicians on the current company. Use this before answering technician count or technician list questions.")]
        public async Task<IReadOnlyCollection<TechnicianInfoResponse>> GetTechnicianInfo(CancellationToken cancellationToken)
        {
            return await _technicianQueryToAI.QueryTechniciansAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }
    }
}
