using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public class PaymentService : IPaymentService
{
    private readonly AccountingDbContext _db;

    public PaymentService(AccountingDbContext db)
    {
        _db = db;
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
            FeeAmount = 0,
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

    public async Task<Payment?> ProcessAsync(Guid tenantId, Guid paymentId, CancellationToken ct = default)
    {
        var payment = await _db.Payments
            .Include(p => p.Invoice)
            .FirstOrDefaultAsync(x => x.Id == paymentId && x.TenantId == tenantId, ct);

        if (payment is null || payment.Status != PaymentStatus.Beklemede)
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
