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

    private readonly IInvoicePdfService _invoicePdfService;
    private readonly IBus _bus;

    public PaymentService(AccountingDbContext db, ICariHesapService cariHesapService, 
    IInvoiceService invoiceService, IInvoicePdfService invoicePdfService, IBus bus)
    {
        _db = db;
        _cariHesapService = cariHesapService;
        _invoiceService = invoiceService;
        _invoicePdfService = invoicePdfService;
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

        // Update account balance (decrease as payment received)
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == payment.AccountId && x.TenantId == tenantId, ct);

        if (account != null)
        {
            account.Balance -= payment.NetAmount;
            account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        }

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
        Guid? invoiceId = null;
        Guid? paymentId = null;

        using var tx = await _db.Database.BeginTransactionAsync(ct);
        var account = await _db.Accounts.FirstOrDefaultAsync(x => x.Id == PaymentRequest.AccountId && x.TenantId == tenantId, ct);
        if (account == null)
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
                "Account not found.",
                ct);
            return false;
        }
        var invoice = await _invoiceService.CreateAsync(tenantId, invoiceRequest, "trade-accounting-consumer", ct);
        invoiceId = invoice.Id;

        if (invoice is null)
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
                "Invoice create failed.",
                ct);
            return false;
        }

        var invoiceLineItem = await _invoiceService.AddLineItemAsync(tenantId, invoice.Id, invoiceLineItemRequest, "trade-accounting-consumer", ct);

        if (invoiceLineItem is null)
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
                "Invoice line item create failed.",
                ct);
            return false;
        }

        PaymentRequest.InvoiceId = invoice.Id;
        var payment = await CreateAsync(tenantId, PaymentRequest, "trade-accounting-consumer", ct);
        paymentId = payment.Id;
        if (payment is null)
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
                "Payment create failed.",
                ct);
            return false;
        }
        payment.Status = PaymentStatus.Tamamlandi;
        payment.ProcessedAtUtc = DateTimeOffset.UtcNow;
        payment.UpdatedAtUtc = DateTimeOffset.UtcNow;
        invoice.PaidAmount += payment.NetAmount;
        if (invoice.PaidAmount >= invoice.TotalAmount)
        {
            invoice.Status = InvoiceStatus.Paid;
            invoice.PaidDate = DateTimeOffset.UtcNow;

        }
        else
        {
            invoice.Status = InvoiceStatus.PartiallyPaid;
        }
        var hareket = await _cariHesapService.CreateHareketAsync(
                tenantId,
                payment.BranchId,
                new CreateCariHesapHareketiRequest
                {
                    AccountId = payment.AccountId,
                    CustomerId = payment.CustomerId,
                    HareketTipi = isPurchase ? HareketTipi.Borc : HareketTipi.Alacak,
                    Tutar = payment.NetAmount,
                    Aciklama = $"{(isPurchase ? "Alış" : "Satış")} - PaymentNo: {payment.PaymentNumber}",
                    ReferansNumarasi = PaymentRequest.ReferenceNumber,
                    BelgeNumarasi = payment.PaymentNumber,
                    IslemTarihi = payment.PaymentDate,
                    InvoiceId = invoice.Id,
                    PaymentId = payment.Id
                },
                "trade-accounting-consumer",
                ct);
        var faturaPDF =  _invoicePdfService.Generate(invoice);
        if (faturaPDF == null)
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
                "Invoice PDF generation failed.",
                ct);
            return false;
        }
        if (hareket == null)
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
                "Cari hareket create failed.",
                ct);
            return false;
        }
        try
        {
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

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
        catch (DbUpdateException)
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
                "Db update error while processing payment.",
                ct);
            return false;
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
