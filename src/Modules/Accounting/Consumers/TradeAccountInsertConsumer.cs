using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Services;
using TechSupport.Trade.Contracts.Events;

namespace TechSupport.Accounting.Consumers
{
    public class TradeAccountInsertConsumer : IConsumer<TradeAccountModuleInserted>
    {
        private readonly AccountingDbContext _db;
        private readonly ICariHesapService _cariHesapService;

        private readonly IPaymentService _paymentService;

        private readonly IInvoiceService _invoiceService;

        private readonly ILogger<TradeAccountInsertConsumer> _logger;

        public TradeAccountInsertConsumer(AccountingDbContext db, ICariHesapService cariHesapService, IPaymentService paymentService, IInvoiceService invoiceService, ILogger<TradeAccountInsertConsumer> logger)
        {
            _db = db;
            _cariHesapService = cariHesapService;
            _paymentService = paymentService;
            _invoiceService = invoiceService;
            _logger = logger;
        }

        public async Task Consume(ConsumeContext<TradeAccountModuleInserted> context)
        {
            var message = context.Message;

            var movementReference = message.IdempotencyKey;
            var alreadyProcessed = await _db.CariHesapHareketleri
                .AsNoTracking()
                .AnyAsync(
                    x => x.TenantId == message.TenantId && x.ReferansNumarasi == movementReference,
                    context.CancellationToken);

            if (alreadyProcessed)
                return;

            var account = await _db.Accounts
                .FirstOrDefaultAsync(x => x.TenantId == message.TenantId, context.CancellationToken);

            if (account is null)
            {
                account = new Account
                {
                    Id = Guid.NewGuid(),
                    TenantId = message.TenantId,
                    BranchId = message.BranchId,
                    Name = "Varsayilan Cari Hesap",
                    AccountNumber = $"ACC-{message.TenantId:N}"[..16],
                    Type = AccountType.CariHesap,
                    Status = AccountStatus.Active,
                    Balance = 0,
                    TotalBorc = 0,
                    TotalAlacak = 0,
                    CreatedAtUtc = DateTimeOffset.UtcNow,
                    CreatedBy = "trade-accounting-consumer"
                };

                await _db.Accounts.AddAsync(account, context.CancellationToken);
                await _db.SaveChangesAsync(context.CancellationToken);
            }
     
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
                UnitPrice = message.UnitPrice,
                ProductCode = $"TRADE-{message.TradeId:N}",
                TaxRate = 0.18m
            };

            var payment = new CreatePaymentRequest
            {
                AccountId = account.Id,
                CustomerId = message.CustomerId,
                InvoiceId = invoice.Id,
                Amount = message.TotalAmount,
                PaymentNumber = $"PAY-TRADE-{message.TradeId:N}",
                PaymentDate = message.OccurredAtUtc,
                ReferenceNumber = movementReference,
                Method = message.PaymentMethod switch
                {
                    Trade.Contracts.Events.PaymentMethod.Cash => Domain.Entities.PaymentMethod.Nakit,
                    Trade.Contracts.Events.PaymentMethod.Card => Domain.Entities.PaymentMethod.KrediKarti,
                    Trade.Contracts.Events.PaymentMethod.Transfer => Domain.Entities.PaymentMethod.BankaHavalesi,
                    _ => Domain.Entities.PaymentMethod.Nakit
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
                 // Log the failure and consider retrying or compensating actions
        }
    }
}