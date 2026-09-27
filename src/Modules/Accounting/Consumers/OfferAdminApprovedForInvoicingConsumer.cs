using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Accounting.Services;
using TechSupport.Operation.Contracts.Events;

namespace TechSupport.Accounting.Consumers;

public sealed class OfferAdminApprovedForInvoicingConsumer : IConsumer<OfferAdminApprovedForInvoicing>
{
    private readonly AccountingDbContext _db;
    private readonly IAccountService _accountService;

    public OfferAdminApprovedForInvoicingConsumer(
        AccountingDbContext db,
        IAccountService accountService)
    {
        _db = db;
        _accountService = accountService;
    }

    public async Task Consume(ConsumeContext<OfferAdminApprovedForInvoicing> context)
    {
        var msg = context.Message;

        var account = await _accountService.EnsureDefaultAsync(
            msg.TenantId,
            msg.BranchId,
            "operation.offer-admin-approve",
            context.CancellationToken);

        var invoiceNumber = BuildInvoiceNumber(msg.OfferId);

        // Idempotency: if the deterministic invoice number already exists, no-op.
        var alreadyExists = await _db.Invoices
            .AsNoTracking()
            .AnyAsync(x => x.TenantId == msg.TenantId && x.InvoiceNumber == invoiceNumber, context.CancellationToken);
        if (alreadyExists)
            return;

        await using var tx = await _db.Database.BeginTransactionAsync(context.CancellationToken);

        var now = DateTimeOffset.UtcNow;
        var invoiceId = Guid.NewGuid();

        var lineItems = new List<InvoiceLineItem>();
        var lineNumber = 1;

        foreach (var item in msg.Items)
        {
            lineItems.Add(new InvoiceLineItem
            {
                Id = Guid.NewGuid(),
                TenantId = msg.TenantId,
                BranchId = msg.BranchId,
                InvoiceId = invoiceId,
                LineNumber = lineNumber++,
                Description = $"Parca - {item.Name}",
                ProductCode = item.StockItemId.ToString("N")[..12],
                Quantity = item.Quantity,
                Unit = "adet",
                UnitPrice = item.UnitPrice,
                TaxRate = 0m,
                TaxAmount = 0m,
                LineTotal = item.Quantity * item.UnitPrice,
                CreatedAtUtc = now,
                CreatedBy = "operation.offer-admin-approve"
            });
        }

        if (msg.LaborAmount > 0m)
        {
            lineItems.Add(new InvoiceLineItem
            {
                Id = Guid.NewGuid(),
                TenantId = msg.TenantId,
                BranchId = msg.BranchId,
                InvoiceId = invoiceId,
                LineNumber = lineNumber,
                Description = "Iscilik",
                ProductCode = "LABOR",
                Quantity = 1m,
                Unit = "hizmet",
                UnitPrice = msg.LaborAmount,
                TaxRate = 0m,
                TaxAmount = 0m,
                LineTotal = msg.LaborAmount,
                CreatedAtUtc = now,
                CreatedBy = "operation.offer-admin-approve"
            });
        }

        var subtotal = lineItems.Sum(x => x.LineTotal);

        var invoice = new Invoice
        {
            Id = invoiceId,
            TenantId = msg.TenantId,
            BranchId = msg.BranchId,
            AccountId = account.Id,
            CustomerId = msg.CustomerId,
            InvoiceNumber = invoiceNumber,
            Status = InvoiceStatus.Draft,
            Type = InvoiceType.ProForma,
            IssueDate = now,
            DueDate = now.AddDays(7),
            Subtotal = subtotal,
            TaxAmount = 0m,
            TotalAmount = subtotal,
            PaidAmount = 0m,
            Notes = $"Operation:{msg.OperationId} Offer:{msg.OfferId} Currency:{msg.Currency}",
            CreatedAtUtc = now,
            CreatedBy = "operation.offer-admin-approve"
        };

        await _db.Invoices.AddAsync(invoice, context.CancellationToken);
        await _db.InvoiceLineItems.AddRangeAsync(lineItems, context.CancellationToken);
        await _db.SaveChangesAsync(context.CancellationToken);
        await tx.CommitAsync(context.CancellationToken);
    }

    private static string BuildInvoiceNumber(Guid offerId) => $"OFR-{offerId:N}";
}
