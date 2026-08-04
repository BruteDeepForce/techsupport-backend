using System.Security.Cryptography;
using System.Text;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Trade.Contracts.Events;

namespace TechSupport.Accounting.Consumers;

public sealed class QuickSaleAccountingRequestedConsumer(AccountingDbContext dbContext, IPublishEndpoint publisher)
    : IConsumer<QuickSaleAccountingRequested>
{
    public async Task Consume(ConsumeContext<QuickSaleAccountingRequested> context)
    {
        var message = context.Message;
        var consumerName = nameof(QuickSaleAccountingRequestedConsumer);
        if (await ReplayIfProcessed(message.MessageId, consumerName, context.CancellationToken)) return;

        if (message.TotalAmount < 0 || message.PaidAmount < 0 || message.PaidAmount > message.TotalAmount)
        {
            await PublishBusinessFailure(message, consumerName, "Hızlı satış tutarları Accounting kurallarına uygun değil.", context.CancellationToken);
            return;
        }

        await using var transaction = await dbContext.Database.BeginTransactionAsync(context.CancellationToken);
        var now = DateTimeOffset.UtcNow;
        var auditUser = $"quicksale:{message.QuickSaleId:N}";
        var customerId = StableGuid($"walk-in:{message.TenantId:N}:{message.BranchId:N}");

        var account = await dbContext.Accounts.SingleOrDefaultAsync(x => x.TenantId == message.TenantId, context.CancellationToken);
        if (account is null)
        {
            account = new Account
            {
                Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                AccountNumber = $"QS-{message.TenantId:N}", Name = "Hızlı Satış Cari Hesabı",
                Type = AccountType.CariHesap, Status = AccountStatus.Active, CreatedBy = auditUser
            };
            dbContext.Accounts.Add(account);
        }

        var invoice = new Invoice
        {
            Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
            AccountId = account.Id, CustomerId = customerId, InvoiceNumber = $"QS-{message.QuickSaleId:N}",
            Status = message.PaidAmount == message.TotalAmount ? InvoiceStatus.Paid :
                message.PaidAmount > 0 ? InvoiceStatus.PartiallyPaid : InvoiceStatus.Issued,
            Type = InvoiceType.Standard, IssueDate = now, DueDate = now,
            PaidDate = message.PaidAmount == message.TotalAmount ? now : null,
            Subtotal = message.Subtotal, TaxAmount = 0, TotalAmount = message.TotalAmount,
            PaidAmount = message.PaidAmount, Notes = $"Hızlı satış: {message.SaleNumber}", CreatedBy = auditUser
        };
        dbContext.Invoices.Add(invoice);

        var lineNumber = 1;
        foreach (var item in message.Items)
        {
            dbContext.InvoiceLineItems.Add(new InvoiceLineItem
            {
                Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                InvoiceId = invoice.Id, LineNumber = lineNumber++, Description = item.ProductName,
                ProductCode = item.Sku, Quantity = item.Quantity, Unit = "adet", UnitPrice = item.UnitPrice,
                TaxRate = 0, TaxAmount = 0, LineTotal = item.LineTotal, CreatedBy = auditUser
            });
        }
        if (message.DiscountAmount > 0)
        {
            dbContext.InvoiceLineItems.Add(new InvoiceLineItem
            {
                Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                InvoiceId = invoice.Id, LineNumber = lineNumber, Description = "Satış indirimi",
                ProductCode = "DISCOUNT", Quantity = 1, Unit = "adet", UnitPrice = -message.DiscountAmount,
                LineTotal = -message.DiscountAmount, CreatedBy = auditUser
            });
        }

        Payment? payment = null;
        if (message.PaidAmount > 0)
        {
            payment = new Payment
            {
                Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                AccountId = account.Id, CustomerId = customerId, InvoiceId = invoice.Id,
                PaymentNumber = $"PAY-QS-{message.QuickSaleId:N}", Method = MapPaymentMethod(message.PaymentMethod),
                Status = PaymentStatus.Tamamlandi, Amount = message.PaidAmount, NetAmount = message.PaidAmount,
                ReferenceNumber = message.SaleNumber, Notes = "Hızlı satış tahsilatı", PaymentDate = now,
                ProcessedAtUtc = now, CreatedBy = auditUser
            };
            dbContext.Payments.Add(payment);
        }

        account.TotalBorc += message.TotalAmount;
        account.Balance += message.TotalAmount;
        dbContext.CariHesapHareketleri.Add(new CariHesapHareketi
        {
            Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
            AccountId = account.Id, CustomerId = customerId, InvoiceId = invoice.Id,
            HareketTipi = HareketTipi.Borc, Borc = message.TotalAmount, Bakiye = account.Balance,
            Aciklama = $"Hızlı satış faturası {message.SaleNumber}", ReferansNumarasi = $"QS:{message.QuickSaleId:N}:INVOICE",
            BelgeNumarasi = invoice.InvoiceNumber, IslemTarihi = now, VadeTarihi = now, CreatedBy = auditUser
        });

        if (payment is not null)
        {
            account.TotalAlacak += message.PaidAmount;
            account.Balance -= message.PaidAmount;
            dbContext.CariHesapHareketleri.Add(new CariHesapHareketi
            {
                Id = Guid.NewGuid(), TenantId = message.TenantId, BranchId = message.BranchId,
                AccountId = account.Id, CustomerId = customerId, InvoiceId = invoice.Id, PaymentId = payment.Id,
                HareketTipi = HareketTipi.Alacak, Alacak = message.PaidAmount, Bakiye = account.Balance,
                Aciklama = $"Hızlı satış tahsilatı {message.SaleNumber}", ReferansNumarasi = $"QS:{message.QuickSaleId:N}:PAYMENT",
                BelgeNumarasi = payment.PaymentNumber, IslemTarihi = now, CreatedBy = auditUser
            });
        }

        var succeeded = new QuickSaleAccountingSucceeded(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
            message.TenantId, message.BranchId, message.IdempotencyKey, invoice.Id, payment?.Id, now);
        dbContext.InboxMessages.Add(AccountingInboxMessage.Create(message.MessageId, consumerName, succeeded));
        await dbContext.SaveChangesAsync(context.CancellationToken);
        await transaction.CommitAsync(context.CancellationToken);
        await publisher.Publish(succeeded, context.CancellationToken);
    }

    private async Task PublishBusinessFailure(QuickSaleAccountingRequested message, string consumerName, string reason, CancellationToken ct)
    {
        var failed = new QuickSaleAccountingFailed(Guid.NewGuid(), message.CorrelationId, message.QuickSaleId,
            message.TenantId, message.BranchId, message.IdempotencyKey, reason, DateTimeOffset.UtcNow);
        dbContext.InboxMessages.Add(AccountingInboxMessage.Create(message.MessageId, consumerName, failed));
        await dbContext.SaveChangesAsync(ct);
        await publisher.Publish(failed, ct);
    }

    private async Task<bool> ReplayIfProcessed(Guid id, string consumer, CancellationToken ct)
    {
        var inbox = await dbContext.InboxMessages.AsNoTracking()
            .SingleOrDefaultAsync(x => x.MessageId == id && x.ConsumerName == consumer, ct);
        if (inbox is null) return false;
        var (response, type) = inbox.DeserializeResponse();
        await publisher.Publish(response, type, ct);
        return true;
    }

    private static PaymentMethod MapPaymentMethod(string method) => method switch
    {
        "Cash" => PaymentMethod.Nakit,
        "Card" => PaymentMethod.KrediKarti,
        "Transfer" => PaymentMethod.BankaHavalesi,
        _ => PaymentMethod.Diger
    };

    private static Guid StableGuid(string value)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(value));
        return new Guid(hash.AsSpan(0, 16));
    }
}
