using System.ComponentModel;
using Ai.Services.SemanticKernel;
using Microsoft.SemanticKernel;
using TechSupport.Stock.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class StockActionTool
    {
        private readonly IStockQueryToAI _stockQueryToAI;
        private readonly AiKernelRequestContext _requestContext;

        public StockActionTool(IStockQueryToAI stockQueryToAI, AiKernelRequestContext requestContext)
        {
            _stockQueryToAI = stockQueryToAI;
            _requestContext = requestContext;
        }

        [KernelFunction("Get-Stock-Summary")]
        [Description("Get the overall stock summary for the current company: total item count, critical stock item count, total available and reserved quantities. Use this before answering 'how many items do we have', 'which items are critical', or general stock questions.")]
        public async Task<StockSummaryResponse> GetStockSummary(CancellationToken cancellationToken)
        {
            return await _stockQueryToAI.GetStockSummaryAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }

        [KernelFunction("Get-Stock-Items")]
        [Description("Get the stock items (SKU, name, category, unit price, available and reserved quantities) of the current company. Supports an optional free text search over item name, SKU and category. Use this before answering stock item, stock amount, or price questions.")]
        public async Task<IReadOnlyCollection<StockItemInfoResponse>> GetStockItems(
            string? search,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _stockQueryToAI.QueryStockItemsAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                search,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Stock-Reservations")]
        [Description("Get the stock reservations of the current company with their status (Pending, Approved, Finalized, Released, Rejected). Use this before answering which parts are reserved or pending approval questions.")]
        public async Task<IReadOnlyCollection<StockReservationInfoResponse>> GetStockReservations(
            string? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _stockQueryToAI.QueryStockReservationsAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                status,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Stock-Transactions")]
        [Description("Get the stock movements (stock in, take, consume, return, adjust, reserve) of the current company, optionally within a specific date range. Use this before answering stock movement, stock in/out history questions.")]
        public async Task<IReadOnlyCollection<StockTransactionInfoResponse>> GetStockTransactions(
            System.DateTimeOffset? From,
            System.DateTimeOffset? To,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _stockQueryToAI.QueryStockTransactionsAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                From,
                To,
                page,
                pageSize,
                cancellationToken);
        }
    }
}