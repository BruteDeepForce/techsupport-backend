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

public class InvoiceService : IInvoiceService
{
    private readonly AccountingDbContext _db;

    public InvoiceService(AccountingDbContext db)
    {
        _db = db;
    }

    public async Task<Invoice?> GetByIdAsync(Guid tenantId, Guid invoiceId, CancellationToken ct = default)
    {
        return await _db.Invoices
            .AsNoTracking()
            .Include(i => i.LineItems)
            .Include(i => i.Account)
            .FirstOrDefaultAsync(x => x.Id == invoiceId && x.TenantId == tenantId, ct);
    }

    public async Task<Invoice?> GetByNumberAsync(Guid tenantId, string invoiceNumber, CancellationToken ct = default)
    {
        return await _db.Invoices
            .AsNoTracking()
            .Include(i => i.LineItems)
            .FirstOrDefaultAsync(x => x.InvoiceNumber == invoiceNumber && x.TenantId == tenantId, ct);
    }

    public async Task<PagedInvoiceResponse> ListAsync(Guid tenantId, Guid? accountId = null, InvoiceStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        var query = _db.Invoices
            .AsNoTracking()
            .Include(i => i.Account)
            .Where(x => x.TenantId == tenantId);

        if (accountId.HasValue)
            query = query.Where(x => x.AccountId == accountId.Value);

        if (status.HasValue)
            query = query.Where(x => x.Status == status.Value);

        var totalCount = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(x => x.IssueDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new InvoiceListItemResponse
            {
                Id = x.Id,
                InvoiceNumber = x.InvoiceNumber,
                AccountName = x.Account != null ? x.Account.Name : null,
                Status = x.Status,
                Type = x.Type,
                IssueDate = x.IssueDate,
                DueDate = x.DueDate,
                TotalAmount = x.TotalAmount,
                PaidAmount = x.PaidAmount
            })
            .ToListAsync(ct);

        return new PagedInvoiceResponse
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<Invoice> CreateAsync(Guid tenantId, CreateInvoiceRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        // Check if invoice number already exists
        var exists = await _db.Invoices
            .AnyAsync(x => x.TenantId == tenantId && x.InvoiceNumber == request.InvoiceNumber, ct);
        
        if (exists)
            throw new InvalidOperationException($"Invoice number '{request.InvoiceNumber}' already exists");

        var invoice = new Invoice
        {
            Id = request.Id ?? Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            AccountId = request.AccountId,
            CustomerId = request.CustomerId,
            InvoiceNumber = request.InvoiceNumber.Trim(),
            Status = InvoiceStatus.Draft,
            Type = request.Type,
            IssueDate = request.IssueDate,
            DueDate = request.DueDate,
            Subtotal = 0,
            TaxAmount = 0,
            TotalAmount = 0,
            PaidAmount = 0,
            Notes = request.Notes?.Trim(),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };

        await _db.Invoices.AddAsync(invoice, ct);
        await _db.SaveChangesAsync(ct);
        return invoice;
    }

    public async Task<Invoice?> UpdateAsync(Guid tenantId, UpdateInvoiceRequest request, string? updatedBy = null, CancellationToken ct = default)
    {
        var invoice = await _db.Invoices
            .FirstOrDefaultAsync(x => x.Id == request.Id && x.TenantId == tenantId, ct);

        if (invoice is null) return null;

        if (invoice.Status != InvoiceStatus.Draft)
            throw new InvalidOperationException("Only draft invoices can be updated");

        // Check RowVersion for optimistic concurrency
        if (request.RowVersion == null)
            throw new InvalidOperationException("RowVersion is required for update to ensure data integrity");
        _db.Entry(invoice).Property(x => x.RowVersion).OriginalValue = request.RowVersion;

        if (!string.IsNullOrWhiteSpace(request.InvoiceNumber))
            invoice.InvoiceNumber = request.InvoiceNumber.Trim();

        if (request.Status.HasValue)
            invoice.Status = request.Status.Value;

        if (request.IssueDate.HasValue)
            invoice.IssueDate = request.IssueDate.Value;

        if (request.DueDate.HasValue)
            invoice.DueDate = request.DueDate.Value;
        
        if (!string.IsNullOrWhiteSpace(request.Notes))
            invoice.Notes = request.Notes.Trim();

        invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;
        invoice.UpdatedBy = updatedBy;

        try
        {
            await _db.SaveChangesAsync(ct);
            return invoice;
        }
        catch (DbUpdateConcurrencyException)
        {
            // Re-fetch to check if record still exists
            var entry = _db.Entry(invoice);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null; // Record was deleted by another user
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<Invoice?> AddLineItemAsync(Guid tenantId, Guid invoiceId, AddInvoiceLineItemRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        var invoice = await _db.Invoices
            .Include(i => i.LineItems)
            .FirstOrDefaultAsync(x => x.Id == invoiceId && x.TenantId == tenantId, ct);

        if (invoice is null || invoice.Status != InvoiceStatus.Draft)
            return null;

        var lineTotal = request.Quantity * request.UnitPrice;
        var taxAmount = lineTotal * request.TaxRate;

        var lineItem = new InvoiceLineItem
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = invoice.BranchId,
            InvoiceId = invoiceId,
            LineNumber = invoice.LineItems.Count + 1,
            Description = request.Description.Trim(),
            ProductCode = request.ProductCode?.Trim(),
            Quantity = request.Quantity,
            Unit = request.Unit.Trim(),
            UnitPrice = request.UnitPrice,
            TaxRate = request.TaxRate,
            TaxAmount = taxAmount,
            LineTotal = lineTotal + taxAmount,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };

        await _db.InvoiceLineItems.AddAsync(lineItem, ct);

        // Recalculate invoice totals
        invoice.Subtotal += lineTotal;
        invoice.TaxAmount += taxAmount;
        invoice.TotalAmount = invoice.Subtotal + invoice.TaxAmount;
        invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;
        invoice.UpdatedBy = createdBy;

        try
        {
            await _db.SaveChangesAsync(ct);
            
            // Reload with line items
            await _db.Entry(invoice).Collection(i => i.LineItems).LoadAsync(ct);
            return invoice;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(invoice);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null;
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<Invoice?> RemoveLineItemAsync(Guid tenantId, Guid invoiceId, Guid lineItemId, CancellationToken ct = default)
    {
        var invoice = await _db.Invoices
            .Include(i => i.LineItems)
            .FirstOrDefaultAsync(x => x.Id == invoiceId && x.TenantId == tenantId, ct);

        if (invoice is null || invoice.Status != InvoiceStatus.Draft)
            return null;

        var lineItem = invoice.LineItems.FirstOrDefault(x => x.Id == lineItemId);
        if (lineItem is null) return null;

        // Reverse totals
        invoice.Subtotal -= lineItem.UnitPrice * lineItem.Quantity;
        invoice.TaxAmount -= lineItem.TaxAmount;
        invoice.TotalAmount = invoice.Subtotal + invoice.TaxAmount;

        _db.InvoiceLineItems.Remove(lineItem);
        invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;

        try
        {
            await _db.SaveChangesAsync(ct);
            return invoice;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(invoice);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null;
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<Invoice?> IssueAsync(Guid tenantId, Guid invoiceId, CancellationToken ct = default)
    {
        var invoice = await _db.Invoices
            .Include(i => i.LineItems)
            .FirstOrDefaultAsync(x => x.Id == invoiceId && x.TenantId == tenantId, ct);

        if (invoice is null || invoice.Status != InvoiceStatus.Draft)
            return null;

        if (!invoice.LineItems.Any())
            throw new InvalidOperationException("Cannot issue invoice without line items");

        invoice.Status = InvoiceStatus.Issued;
        invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;

        try
        {
            await _db.SaveChangesAsync(ct);
            return invoice;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(invoice);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null;
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<Invoice?> CancelAsync(Guid tenantId, Guid invoiceId, string? reason = null, CancellationToken ct = default)
    {
        var invoice = await _db.Invoices
            .FirstOrDefaultAsync(x => x.Id == invoiceId && x.TenantId == tenantId, ct);

        if (invoice is null)
            return null;

        if (invoice.Status == InvoiceStatus.Paid)
            throw new InvalidOperationException("Cannot cancel paid invoice");

        invoice.Status = InvoiceStatus.Cancelled;
        invoice.Notes = string.IsNullOrWhiteSpace(reason) ? invoice.Notes : $"{invoice.Notes}\n{reason}";
        invoice.UpdatedAtUtc = DateTimeOffset.UtcNow;

        try
        {
            await _db.SaveChangesAsync(ct);
            return invoice;
        }
        catch (DbUpdateConcurrencyException)
        {
            var entry = _db.Entry(invoice);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null;
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<decimal> GetReceivableAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var unpaidInvoices = await _db.Invoices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.AccountId == accountId && x.Status != InvoiceStatus.Cancelled)
            .ToListAsync(ct);

        return unpaidInvoices.Sum(i => i.TotalAmount - i.PaidAmount);
    }

    public async Task<decimal> GetTotalReceivablesAsync(Guid tenantId, CancellationToken ct = default)
    {
        var unpaidInvoices = await _db.Invoices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.Status != InvoiceStatus.Cancelled && x.Status != InvoiceStatus.Paid)
            .ToListAsync(ct);

        return unpaidInvoices.Sum(i => i.TotalAmount - i.PaidAmount);
    }
}
