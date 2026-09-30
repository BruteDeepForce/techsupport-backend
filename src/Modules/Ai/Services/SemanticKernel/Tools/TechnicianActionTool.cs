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
        [Description("Get all technicians of the current company with their full profile: name, email, phone, profile photo url, active status, employment start date, expertise areas and operation counts (assigned/completed/pending). Use this before answering any technician count, technician list, technician expertise, contact or workload question, and before calling Get-Technician-Detail.")]
        public async Task<IReadOnlyCollection<TechnicianInfoResponse>> GetTechnicianInfo(CancellationToken cancellationToken)
        {
            return await _technicianQueryToAI.QueryTechniciansAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }
        [KernelFunction("Get-Technician-Detail")]
        [Description("Get the full profile of a single technician: contact information, profile photo url, status, employment start date and duration, expertise areas, workload counters and latest work orders. Call Get-Technicians first and pass the technician name exactly as returned there. If the name is empty or no technician matches, the tool returns no data.")]
        public async Task<TechnicianDetailInfoResponse?> GetTechnicianDetail(string technicianName, CancellationToken cancellationToken)
        {
            return await _technicianQueryToAI.QueryTechnicianDetailAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                technicianName,
                cancellationToken);
        }
    }
}
