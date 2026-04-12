using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public interface IPaymentService
{
    // Payment CRUD operations
    Task<Payment?> GetByIdAsync(Guid tenantId, Guid paymentId, CancellationToken ct = default);
    Task<Payment?> GetByNumberAsync(Guid tenantId, string paymentNumber, CancellationToken ct = default);
    Task<PagedPaymentResponse> ListAsync(Guid tenantId, Guid? accountId = null, Guid? invoiceId = null, PaymentStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default);
    Task<Payment> CreateAsync(Guid tenantId, CreatePaymentRequest request, string? createdBy = null, CancellationToken ct = default);
    Task<Payment?> UpdateAsync(Guid tenantId, UpdatePaymentRequest request, string? updatedBy = null, CancellationToken ct = default);
    
    // Payment status operations
    Task<Payment?> ProcessAsync(Guid tenantId, Guid paymentId, CancellationToken ct = default);
    Task<Payment?> FailAsync(Guid tenantId, Guid paymentId, string? reason = null, CancellationToken ct = default);
    Task<Payment?> RefundAsync(Guid tenantId, Guid paymentId, string? reason = null, CancellationToken ct = default);
}
