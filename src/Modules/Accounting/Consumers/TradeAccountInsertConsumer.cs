using MassTransit;
using Microsoft.Extensions.Logging;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Services;
using TechSupport.Trade.Contracts.Events;
using AccountingPaymentMethod = TechSupport.Accounting.Domain.Entities.PaymentMethod;
using InvoiceType = TechSupport.Accounting.Domain.Entities.InvoiceType;

namespace TechSupport.Accounting.Consumers
{
    public class TradeAccountInsertConsumer : IConsumer<TradeAccountModuleInserted>
    {
        private readonly IAccountService _accountService;
        private readonly IPaymentService _paymentService;
        private readonly ILogger<TradeAccountInsertConsumer> _logger;

        public TradeAccountInsertConsumer(
            IAccountService accountService,
            IPaymentService paymentService,
            ILogger<TradeAccountInsertConsumer> logger)
        {
            _accountService = accountService;
            _paymentService = paymentService;
            _logger = logger;
        }

        public async Task Consume(ConsumeContext<TradeAccountModuleInserted> context)
        {
            var message = context.Message;

            if (message.Quantity <= 0)
                throw new InvalidOperationException("Trade quantity must be greater than zero.");

            var paidAmount = message.PaidAmount ?? 0m;
            if (paidAmount < 0m || paidAmount > message.TotalAmount)
                throw new InvalidOperationException("Paid amount must be between zero and the trade total.");

            var account = await _accountService.EnsureDefaultAsync(
                message.TenantId,
                message.BranchId,
                "trade-accounting-consumer",
                context.CancellationToken);
     
            var invoice = new CreateInvoiceRequest()
            {
                Id = Guid.NewGuid(),
                AccountId = account.Id,
                CustomerId = message.CustomerId,
                InvoiceNumber = $"INV-TRADE-{message.TradeId:N}",
                Type = InvoiceType.Standard,
                IssueDate = message.OccurredAtUtc,
                DueDate = message.OccurredAtUtc.AddDays(30),
                Notes = $"Invoice for Trade {message.TradeId}",
                BranchId = message.BranchId
            };

            var lineItem = new AddInvoiceLineItemRequest
            {
                Description = $"Trade {message.TradeId} - {(message.IsPurchase ? "Alış" : "Satış")}",
                Quantity = message.Quantity,
                // Trade.TotalAmount is authoritative because it may include a discount.
                UnitPrice = decimal.Round(message.TotalAmount / message.Quantity, 4),
                ProductCode = $"TRADE-{message.TradeId:N}",
                TaxRate = 0m
            };

            var payment = new CreatePaymentRequest
            {
                AccountId = account.Id,
                CustomerId = message.CustomerId,
                InvoiceId = invoice.Id,
                Amount = paidAmount,
                PaymentNumber = $"PAY-TRADE-{message.TradeId:N}",
                PaymentDate = message.OccurredAtUtc,
                ReferenceNumber = message.IdempotencyKey,
                Method = message.PaymentMethod switch
                {
                    Trade.Contracts.Events.PaymentMethod.Cash => AccountingPaymentMethod.Nakit,
                    Trade.Contracts.Events.PaymentMethod.Card => AccountingPaymentMethod.KrediKarti,
                    Trade.Contracts.Events.PaymentMethod.Transfer => AccountingPaymentMethod.BankaHavalesi,
                    _ => AccountingPaymentMethod.Nakit
                }
            };

            var result = await _paymentService.ProcessPaymentAsyncV2(
                message.TenantId,
                message.TradeId,
                message.BranchId,
                message.IdempotencyKey,
                payment,
                invoice,
                lineItem,
                message.IsPurchase,
                context.CancellationToken);

            if (!result)
            {
                _logger.LogWarning(
                    "Accounting processing failed for TradeId {TradeId}, TenantId {TenantId}",
                    message.TradeId,
                    message.TenantId);
            }
        }
    }
}
