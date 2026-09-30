using System.ComponentModel;
using Ai.Services.SemanticKernel;
using Microsoft.SemanticKernel;
using TechSupport.Accounting.Contracts.AI;

namespace Ai.Services.SemanticKernel.Tools
{
    public class AccountingActionTool
    {
        private readonly IAccountingQueryToAI _accountingQueryToAI;
        private readonly AiKernelRequestContext _requestContext;

        public AccountingActionTool(IAccountingQueryToAI accountingQueryToAI, AiKernelRequestContext requestContext)
        {
            _accountingQueryToAI = accountingQueryToAI;
            _requestContext = requestContext;
        }

        [KernelFunction("Get-Accounting-Summary")]
        [Description("Get the financial summary of the current company: total receivable, total payable, total invoiced, total paid, unpaid amount and overdue invoice count. Use this before answering 'how much money are we waiting for', 'how much is overdue' or general financial questions.")]
        public async Task<AccountingSummaryResponse> GetAccountingSummary(CancellationToken cancellationToken)
        {
            return await _accountingQueryToAI.GetAccountingSummaryAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }

        [KernelFunction("Get-Accounts")]
        [Description("Get the financial accounts (cari hesap, gelir, gider, kasa, banka) of the current company with their balances, total debit (borc) and total credit (alacak). Use this before answering account balance or cash/bank questions.")]
        public async Task<IReadOnlyCollection<AccountInfoResponse>> GetAccounts(CancellationToken cancellationToken)
        {
            return await _accountingQueryToAI.QueryAccountsAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                cancellationToken);
        }

        [KernelFunction("Get-Invoices")]
        [Description("Get the invoices of the current company with their number, status, total, paid and remaining amount and due dates. Supports optional status filter (Draft, Issued, Paid, Overdue, Cancelled, PartiallyPaid, PendingPayment). Use this before answering invoice, billing or overdue invoice questions.")]
        public async Task<IReadOnlyCollection<InvoiceInfoResponse>> GetInvoices(
            string? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _accountingQueryToAI.QueryInvoicesAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                status,
                null,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Payments")]
        [Description("Get the payments/collections of the current company with their number, method, status and amount. Supports optional status filter (Beklemede, Islemede, Tamamlandi, Basarisiz, IadeEdildi). Use this before answering payment or collection questions.")]
        public async Task<IReadOnlyCollection<PaymentInfoResponse>> GetPayments(
            string? status,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _accountingQueryToAI.QueryPaymentsAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                status,
                page,
                pageSize,
                cancellationToken);
        }

        [KernelFunction("Get-Cari-Hesap-Hareketleri")]
        [Description("Get the current account ledger movements (borc/alacak rows with running balance) of the current company, optionally within a specific date range. Use this before answering account statement (ekstre) questions.")]
        public async Task<IReadOnlyCollection<CariHesapHareketInfoResponse>> GetCariHesapHareketleri(
            System.DateTimeOffset? From,
            System.DateTimeOffset? To,
            int page,
            int pageSize,
            CancellationToken cancellationToken)
        {
            return await _accountingQueryToAI.QueryCariHesapHareketleriAsync(
                _requestContext.TenantId,
                _requestContext.BranchId,
                null,
                From,
                To,
                page,
                pageSize,
                cancellationToken);
        }
    }
}