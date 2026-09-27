using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Contracts.Events;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public class PaymentService : IPaymentService
{
    private readonly AccountingDbContext _db;
    private readonly ICariHesapService _cariHesapService;

    private readonly IInvoiceService _invoiceService;

    private readonly IBus _bus;

    public PaymentService(AccountingDbContext db, ICariHesapService cariHesapService, 
    IInvoiceService invoiceService, IBus bus)
    {
        _db = db;
        _cariHesapService = cariHesapService;
        _invoiceService = invoiceService;
        _bus = bus;
    }

    public async Task<Payment?> GetByIdAsync(Guid tenantId, Guid paymentId, CancellationToken ct = default)
    {
        return await _db.Payments
            .AsNoTracking()
            .Include(p => p.Account)
            .Include(p => p.Invoice)
            .FirstOrDefaultAsync(x => x.Id == paymentId && x.TenantId == tenantId, ct);
    }

    public async Task<Payment?> GetByNumberAsync(Guid tenantId, string paymentNumber, CancellationToken ct = default)
    {
        return await _db.Payments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.PaymentNumber == paymentNumber && x.TenantId == tenantId, ct);
    }

    public async Task<PagedPaymentResponse> ListAsync(Guid tenantId, Guid? accountId = null, Guid? invoiceId = null, PaymentStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        var query = _db.Payments
            .AsNoTracking()
            .Include(p => p.Account)
            .Include(p => p.Invoice)
            .Where(x => x.TenantId == tenantId);

        if (accountId.HasValue)
            query = query.Where(x => x.AccountId == accountId.Value);

        if (invoiceId.HasValue)
            query = query.Where(x => x.InvoiceId == invoiceId.Value);

        if (status.HasValue)
            query = query.Where(x => x.Status == status.Value);

        var totalCount = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(x => x.PaymentDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new PaymentListItemResponse
            {
                Id = x.Id,
                PaymentNumber = x.PaymentNumber,
                AccountName = x.Account != null ? x.Account.Name : null,
                InvoiceNumber = x.Invoice != null ? x.Invoice.InvoiceNumber : null,
                Method = x.Method,
                Status = x.Status,
                Amount = x.Amount,
                PaymentDate = x.PaymentDate
            })
            .ToListAsync(ct);

        return new PagedPaymentResponse
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<Payment> CreateAsync(Guid tenantId, CreatePaymentRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        if (request.Amount <= 0m)
            throw new ArgumentOutOfRangeException(nameof(request.Amount), "Payment amount must be greater than zero.");

        if (string.IsNullOrWhiteSpace(request.PaymentNumber))
            throw new ArgumentException("Payment number is required.", nameof(request.PaymentNumber));

        var accountExists = await _db.Accounts.AnyAsync(
            x => x.TenantId == tenantId && x.Id == request.AccountId,
            ct);
        if (!accountExists)
            throw new InvalidOperationException("Account not found for tenant.");

        if (request.InvoiceId.HasValue)
        {
            var invoice = await _db.Invoices
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    x => x.TenantId == tenantId && x.Id == request.InvoiceId.Value,
                    ct);
            if (invoice is null)
                throw new InvalidOperationException("Invoice not found for tenant.");
            if (invoice.AccountId != request.AccountId || invoice.CustomerId != request.CustomerId)
                throw new InvalidOperationException("Payment account/customer does not match the invoice.");
            if (request.Amount > invoice.TotalAmount - invoice.PaidAmount)
                throw new InvalidOperationException("Payment amount cannot exceed the invoice balance.");
        }

        // Check if payment number already exists
        var exists = await _db.Payments
            .AnyAsync(x => x.TenantId == tenantId && x.PaymentNumber == request.PaymentNumber, ct);

        if (exists)
            throw new InvalidOperationException($"Payment number '{request.PaymentNumber}' already exists");

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            AccountId = request.AccountId,
            CustomerId = request.CustomerId,
            InvoiceId = request.InvoiceId,
            PaymentNumber = request.PaymentNumber.Trim(),
            Method = request.Method,
            Status = PaymentStatus.Beklemede,
            Amount = request.Amount,
            FeeAmount = 0,  //! incelenecek
            NetAmount = request.Amount,
            ReferenceNumber = request.ReferenceNumber?.Trim(),
            Notes = request.Notes?.Trim(),
            PaymentDate = request.PaymentDate,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };

        await _db.Payments.AddAsync(payment, ct);
        await _db.SaveChangesAsync(ct);

        return payment;
    }

    public async Task<Payment?> UpdateAsync(Guid tenantId, UpdatePaymentRequest request, string? updatedBy = null, CancellationToken ct = default)
    {
        var payment = await _db.Payments
            .FirstOrDefaultAsync(x => x.Id == request.Id && x.TenantId == tenantId, ct);

        if (payment is null) return null;

        if (payment.Status != PaymentStatus.Beklemede)
            throw new InvalidOperationException("Only pending payments can be updated");

        // Check RowVersion for optimistic concurrency
        if (request.RowVersion == null)
            throw new InvalidOperationException("RowVersion is required for update to ensure data integrity");
        _db.Entry(payment).Property(x => x.RowVersion).OriginalValue = request.RowVersion;

        if (!string.IsNullOrWhiteSpace(request.PaymentNumber))
            payment.PaymentNumber = request.PaymentNumber.Trim();

        if (request.Method.HasValue)
            payment.Method = request.Method.Value;

        if (request.Status.HasValue)
            payment.Status = request.Status.Value;

        if (request.Amount.HasValue)
        {
            payment.Amount = request.Amount.Value;
            payment.NetAmount = request.Amount.Value;
        }

        if (!string.IsNullOrWhiteSpace(request.ReferenceNumber))
            payment.ReferenceNumber = request.ReferenceNumber.Trim();

        if (!string.IsNullOrWhiteSpace(request.Notes))
            payment.Notes = request.Notes.Trim();

        if (request.PaymentDate.HasValue)
            payment.PaymentDate = request.PaymentDate.Value;

        payment.UpdatedAtUtc = DateTimeOffset.UtcNow;
        payment.UpdatedBy = updatedBy;

        try
        {
            await _db.SaveChangesAsync(ct);
            return payment;
        }
        catch (DbUpdateConcurrencyException)
        {
            // Re-fetch to check if record still exists
            var entry = _db.Entry(payment);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);

            if (databaseValues == null)
                return null; // Record was deleted by another user

            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    [Obsolete("[DEPRECATED] Use ProcessPaymentAsyncV2 for better consistency and error handling")]
    public async Task<Payment?> ProcessAsync(Guid tenantId, Guid paymentId, CancellationToken ct = default)
    {
        var payment = await _db.Payments
            .Include(p => p.Invoice)
            .FirstOrDefaultAsync(x => x.Id == paymentId && x.TenantId == tenantId, ct);

        if (payment is null)
            return null;

        if (payment.Status == PaymentStatus.Tamamlandi)
            return payment;

        if (payment.Status != PaymentStatus.Beklemede)
            return null;

        payment.Status = PaymentStatus.Tamamlandi;
        payment.ProcessedAtUtc = DateTimeOffset.UtcNow;
        payment.UpdatedAtUtc = DateTimeOffset.UtcNow;

        // If payment is linked to an invoice, update invoice paid amount
        if (payment.InvoiceId.HasValue && payment.Invoice != null)
        {
            payment.Invoice.PaidAmount += payment.NetAmount;

            if (payment.Invoice.PaidAmount >= payment.Invoice.TotalAmount)
            {
                payment.Invoice.Status = InvoiceStatus.Paid;
                payment.Invoice.PaidDate = DateTimeOffset.UtcNow;
            }
            else if (payment.Invoice.PaidAmount > 0)
            {
                payment.Invoice.Status = InvoiceStatus.PartiallyPaid;
            }

            payment.Invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }

        try
        {
            await _db.SaveChangesAsync(ct);

            await _cariHesapService.CreateHareketAsync(
                tenantId,
                payment.BranchId,
                new CreateCariHesapHareketiRequest
                {
                    AccountId = payment.AccountId,
                    CustomerId = payment.CustomerId,
                    HareketTipi = HareketTipi.Alacak,
                    Tutar = payment.NetAmount,
                    Aciklama = $"Odeme tahsil edildi. PaymentNo: {payment.PaymentNumber}",
                    ReferansNumarasi = payment.ReferenceNumber,
                    BelgeNumarasi = payment.PaymentNumber,
                    IslemTarihi = payment.PaymentDate,
                    InvoiceId = payment.InvoiceId,
                    PaymentId = payment.Id
                },
                payment.UpdatedBy,
                ct);

            return payment;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(payment);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);

            if (databaseValues == null)
                return null;

            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<bool> ProcessPaymentAsyncV2(Guid tenantId,
    Guid tradeId,
    Guid? branchId,
    string idempotencyKey,
    CreatePaymentRequest PaymentRequest,
    CreateInvoiceRequest invoiceRequest,
    AddInvoiceLineItemRequest invoiceLineItemRequest,
    bool isPurchase,
    CancellationToken ct = default)
    {
        var existingInvoice = await _db.Invoices
            .AsNoTracking()
            .FirstOrDefaultAsync(
                x => x.TenantId == tenantId && x.InvoiceNumber == invoiceRequest.InvoiceNumber,
                ct);

        if (existingInvoice is not null)
        {
            var existingPaymentId = await _db.Payments
                .AsNoTracking()
                .Where(x => x.TenantId == tenantId && x.InvoiceId == existingInvoice.Id)
                .Select(x => (Guid?)x.Id)
                .FirstOrDefaultAsync(ct);

            await PublishTradeAccountingProcessResultAsync(
                tradeId,
                tenantId,
                branchId,
                idempotencyKey,
                AccountingProcessStatus.Success,
                existingInvoice.Id,
                existingPaymentId,
                null,
                ct);
            return true;
        }

        Guid? invoiceId = null;
        Guid? paymentId = null;
        await using var tx = await _db.Database.BeginTransactionAsync(ct);

        try
        {
            var accountExists = await _db.Accounts.AnyAsync(
                x => x.Id == PaymentRequest.AccountId && x.TenantId == tenantId,
                ct);
            if (!accountExists)
                throw new InvalidOperationException("Account not found.");

            var invoice = await _invoiceService.CreateAsync(
                tenantId,
                invoiceRequest,
                "trade-accounting-consumer",
                ct);
            invoiceId = invoice.Id;

            var invoiceWithLine = await _invoiceService.AddLineItemAsync(
                tenantId,
                invoice.Id,
                invoiceLineItemRequest,
                "trade-accounting-consumer",
                ct);
            if (invoiceWithLine is null)
                throw new InvalidOperationException("Invoice line item could not be created.");

            invoice = invoiceWithLine;
            var paidAmount = PaymentRequest.Amount;
            if (paidAmount < 0m || paidAmount > invoice.TotalAmount)
                throw new InvalidOperationException("Paid amount must be between zero and the invoice total.");

            // An invoice changes the customer's balance; a payment is a separate,
            // opposite ledger movement. Keeping both is required for a real statement.
            await _cariHesapService.CreateHareketAsync(
                tenantId,
                branchId,
                new CreateCariHesapHareketiRequest
                {
                    AccountId = invoice.AccountId,
                    CustomerId = invoice.CustomerId,
                    HareketTipi = isPurchase ? HareketTipi.Alacak : HareketTipi.Borc,
                    Tutar = invoice.TotalAmount,
                    Aciklama = $"{(isPurchase ? "Alış" : "Satış")} faturası - {invoice.InvoiceNumber}",
                    ReferansNumarasi = $"{idempotencyKey}:invoice",
                    BelgeNumarasi = invoice.InvoiceNumber,
                    IslemTarihi = invoice.IssueDate,
                    VadeTarihi = invoice.DueDate,
                    InvoiceId = invoice.Id
                },
                "trade-accounting-consumer",
                ct);

            if (paidAmount > 0m)
            {
                PaymentRequest.InvoiceId = invoice.Id;
                var payment = await CreateAsync(
                    tenantId,
                    PaymentRequest,
                    "trade-accounting-consumer",
                    ct);
                paymentId = payment.Id;
                payment.Status = PaymentStatus.Tamamlandi;
                payment.ProcessedAtUtc = DateTimeOffset.UtcNow;
                payment.UpdatedAtUtc = DateTimeOffset.UtcNow;

                invoice.PaidAmount = paidAmount;
                invoice.Status = paidAmount >= invoice.TotalAmount
                    ? InvoiceStatus.Paid
                    : InvoiceStatus.PartiallyPaid;
                invoice.PaidDate = invoice.Status == InvoiceStatus.Paid
                    ? DateTimeOffset.UtcNow
                    : null;

                await _cariHesapService.CreateHareketAsync(
                    tenantId,
                    payment.BranchId,
                    new CreateCariHesapHareketiRequest
                    {
                        AccountId = payment.AccountId,
                        CustomerId = payment.CustomerId,
                        HareketTipi = isPurchase ? HareketTipi.Borc : HareketTipi.Alacak,
                        Tutar = payment.NetAmount,
                        Aciklama = $"{(isPurchase ? "Alış ödemesi" : "Satış tahsilatı")} - {payment.PaymentNumber}",
                        ReferansNumarasi = $"{idempotencyKey}:payment",
                        BelgeNumarasi = payment.PaymentNumber,
                        IslemTarihi = payment.PaymentDate,
                        InvoiceId = invoice.Id,
                        PaymentId = payment.Id
                    },
                    "trade-accounting-consumer",
                    ct);
            }
            else
            {
                invoice.Status = InvoiceStatus.Issued;
                invoice.PaidAmount = 0m;
                invoice.PaidDate = null;
            }

            invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;
            invoice.UpdatedBy = "trade-accounting-consumer";
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch (OperationCanceledException)
        {
            await tx.RollbackAsync(ct);
            throw;
        }
        catch (Exception ex)
        {
            await tx.RollbackAsync(ct);
            await PublishTradeAccountingProcessResultAsync(
                tradeId,
                tenantId,
                branchId,
                idempotencyKey,
                AccountingProcessStatus.Failed,
                invoiceId,
                paymentId,
                $"Unexpected error: {ex.Message}",
                ct);
            return false;
        }

        // Publish after commit. The consumer retry and idempotency branch ensure that
        // a temporary broker failure republishes the same successful result.
        await PublishTradeAccountingProcessResultAsync(
            tradeId,
            tenantId,
            branchId,
            idempotencyKey,
            AccountingProcessStatus.Success,
            invoiceId,
            paymentId,
            null,
            ct);
        return true;
    }

    private Task PublishTradeAccountingProcessResultAsync(
        Guid tradeId,
        Guid tenantId,
        Guid? branchId,
        string idempotencyKey,
        AccountingProcessStatus status,
        Guid? invoiceId,
        Guid? paymentId,
        string? errorMessage,
        CancellationToken ct)
    {
        return _bus.Publish(
            new TradeAccountingProcessResulted(
                TradeId: tradeId,
                TenantId: tenantId,
                BranchId: branchId,
                IdempotencyKey: idempotencyKey,
                Status: status,
                InvoiceId: invoiceId,
                PaymentId: paymentId,
                ErrorMessage: errorMessage,
                OccurredAtUtc: DateTimeOffset.UtcNow),
            ct);
    }

    public async Task<Payment?> FailAsync(Guid tenantId, Guid paymentId, string? reason = null, CancellationToken ct = default)
    {
        var payment = await _db.Payments
            .FirstOrDefaultAsync(x => x.Id == paymentId && x.TenantId == tenantId, ct);

        if (payment is null || payment.Status != PaymentStatus.Beklemede)
            return null;

        payment.Status = PaymentStatus.Basarisiz;
        payment.Notes = string.IsNullOrWhiteSpace(reason) ? payment.Notes : $"{payment.Notes}\n{reason}";
        payment.UpdatedAtUtc = DateTimeOffset.UtcNow;

        try
        {
            await _db.SaveChangesAsync(ct);
            return payment;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(payment);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);

            if (databaseValues == null)
                return null;

            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<Payment?> RefundAsync(Guid tenantId, Guid paymentId, string? reason = null, CancellationToken ct = default)
    {
        var payment = await _db.Payments
            .Include(p => p.Invoice)
            .FirstOrDefaultAsync(x => x.Id == paymentId && x.TenantId == tenantId, ct);

        if (payment is null || payment.Status != PaymentStatus.Tamamlandi)
            return null;

        payment.Status = PaymentStatus.IadeEdildi;
        payment.Notes = string.IsNullOrWhiteSpace(reason) ? payment.Notes : $"{payment.Notes}\n{reason}";
        payment.UpdatedAtUtc = DateTimeOffset.UtcNow;

        // Reverse account balance
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == payment.AccountId && x.TenantId == tenantId, ct);

        if (account != null)
        {
            account.Balance += payment.NetAmount;
            account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }

        // Reverse invoice paid amount if linked
        if (payment.InvoiceId.HasValue && payment.Invoice != null)
        {
            payment.Invoice.PaidAmount -= payment.NetAmount;

            if (payment.Invoice.PaidAmount <= 0)
            {
                payment.Invoice.Status = InvoiceStatus.Issued;
                payment.Invoice.PaidDate = null;
            }
            else
            {
                payment.Invoice.Status = InvoiceStatus.PartiallyPaid;
            }

            payment.Invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }

        try
        {
            await _db.SaveChangesAsync(ct);
            return payment;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(payment);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);

            if (databaseValues == null)
                return null;

            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }
}
