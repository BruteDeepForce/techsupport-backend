using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public interface IInvoiceService
{
    // Invoice CRUD operations
    Task<Invoice?> GetByIdAsync(Guid tenantId, Guid invoiceId, CancellationToken ct = default);
    Task<Invoice?> GetByNumberAsync(Guid tenantId, string invoiceNumber, CancellationToken ct = default);
    Task<PagedInvoiceResponse> ListAsync(Guid tenantId, Guid? accountId = null, InvoiceStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default);
    Task<Invoice> CreateAsync(Guid tenantId, CreateInvoiceRequest request, string? createdBy = null, CancellationToken ct = default);
    Task<Invoice?> UpdateAsync(Guid tenantId, UpdateInvoiceRequest request, string? updatedBy = null, CancellationToken ct = default);
    
    // Invoice line item operations
    Task<Invoice?> AddLineItemAsync(Guid tenantId, Guid invoiceId, AddInvoiceLineItemRequest request, string? createdBy = null, CancellationToken ct = default);
    Task<Invoice?> RemoveLineItemAsync(Guid tenantId, Guid invoiceId, Guid lineItemId, CancellationToken ct = default);
    
    // Invoice status operations
    Task<Invoice?> IssueAsync(Guid tenantId, Guid invoiceId, CancellationToken ct = default);
    Task<Invoice?> CancelAsync(Guid tenantId, Guid invoiceId, string? reason = null, CancellationToken ct = default);
    
    // Financial calculations
    Task<decimal> GetReceivableAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    Task<decimal> GetTotalReceivablesAsync(Guid tenantId, CancellationToken ct = default);
}
