using System.ComponentModel;
using Ai.Services.SemanticKernel;
using Microsoft.SemanticKernel;
using TechSupport.Customer.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class CustomerActionTool
    {
        private readonly ICustomerQueryToAI _customerQueryToAI;
        private readonly AiKernelRequestContext _requestContext;

        public CustomerActionTool(ICustomerQueryToAI customerQueryToAI, AiKernelRequestContext requestContext)
        {
            _customerQueryToAI = customerQueryToAI;
            _requestContext = requestContext;
        }

        [KernelFunction("Get-Customer-Summary")]
        [Description("Get the customer summary of the current company: total customer count, total device count, active devices, expired warranty devices and devices with reported problems. Use this before answering 'how many customers do we have' or general customer questions.")]
        public async Task<CustomerSummaryResponse> GetCustomerSummary(CancellationToken cancellationToken)
        {
            return await _customerQueryToAI.GetCustomerSummaryAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }

        [KernelFunction("Get-Customers")]
        [Description("Get the customers of the current company with their name, email, phone and device count. Supports an optional free text search over name, email and phone. Use this before answering customer list or lookup questions.")]
        public async Task<IReadOnlyCollection<CustomerInfoResponse>> GetCustomers(
            string? search,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _customerQueryToAI.QueryCustomersAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                search,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Customer-Devices")]
        [Description("Get the devices registered to the customers of the current company, including brand, model, serial number, reported problem, status and warranty end date. Supports an optional customerId to list only that customer's devices. Use this before answering device ownership, warranty or device problem questions.")]
        public async Task<IReadOnlyCollection<CustomerDeviceInfoResponse>> GetCustomerDevices(
            System.Guid? customerId,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _customerQueryToAI.QueryCustomerDevicesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                customerId,
                page,
                pageSize,
                cancellationToken);
        }
    }
}