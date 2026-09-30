using System.ComponentModel;
using Ai.Services.SemanticKernel;
using Microsoft.SemanticKernel;
using TechSupport.Hr.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class HrActionTool
    {
        private readonly IHrQueryToAI _hrQueryToAI;
        private readonly AiKernelRequestContext _requestContext;

        public HrActionTool(IHrQueryToAI hrQueryToAI, AiKernelRequestContext requestContext)
        {
            _hrQueryToAI = hrQueryToAI;
            _requestContext = requestContext;
        }

        [KernelFunction("Get-Hr-Summary")]
        [Description("Get the human resources summary of the current company: total employee count, active and on-leave employee count, pending leave requests and total/pending advance amounts. Use this before answering 'how many employees do we have' or general HR questions.")]
        public async Task<HrSummaryResponse> GetHrSummary(CancellationToken cancellationToken)
        {
            return await _hrQueryToAI.GetHrSummaryAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }

        [KernelFunction("Get-Employees")]
        [Description("Get the employees of the current company with their employee number, department, position and status. Supports an optional free text search over name, employee number, email and phone. Use this before answering employee list, department or position questions.")]
        public async Task<IReadOnlyCollection<EmployeeInfoResponse>> GetEmployees(
            string? search,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _hrQueryToAI.QueryEmployeesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                search,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Leaves")]
        [Description("Get the leave requests of the current company with employee, department, leave type, status and dates. Supports optional status filter (Pending, Approved, Rejected). Use this before answering leave, holiday or absence questions.")]
        public async Task<IReadOnlyCollection<LeaveInfoResponse>> GetLeaves(
            string? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _hrQueryToAI.QueryLeavesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                status,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Advances")]
        [Description("Get the salary advance requests of the current company with employee, department, amount, status and reason. Supports optional status filter (Pending, Approved, Rejected). Use this before answering advance or avans questions.")]
        public async Task<IReadOnlyCollection<AdvanceInfoResponse>> GetAdvances(
            string? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _hrQueryToAI.QueryAdvancesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                status,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Employee-Performances")]
        [Description("Get the monthly employee performance reports of the current company with assigned, completed, pending and overdue task counts plus reward, penalty and leave counts. Supports optional year and month filters. Use this before answering employee performance questions.")]
        public async Task<IReadOnlyCollection<EmployeePerformanceInfoResponse>> GetEmployeePerformances(
            int? year,
            int? month,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _hrQueryToAI.QueryEmployeePerformancesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                year,
                month,
                page,
                pageSize,
                cancellationToken);
        }
    }
}