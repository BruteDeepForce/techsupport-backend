using System;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.DTO;

// ==================== Invoice DTOs ====================

public class CreateInvoiceRequest
{
    public Guid? Id { get; set; }
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public InvoiceType Type { get; set; } = InvoiceType.Standard;
    public DateTimeOffset IssueDate { get; set; }
    public DateTimeOffset DueDate { get; set; }
    public string? Notes { get; set; }
    public Guid? BranchId { get; set; }
}

public class AddInvoiceLineItemRequest
{
    public string Description { get; set; } = string.Empty;
    public string? ProductCode { get; set; }
    public decimal Quantity { get; set; }
    public string Unit { get; set; } = "pcs";
    public decimal UnitPrice { get; set; }
    public decimal TaxRate { get; set; }
}

public class UpdateInvoiceRequest
{
    public Guid Id { get; set; }
    public string? InvoiceNumber { get; set; }
    public InvoiceStatus? Status { get; set; }
    public DateTimeOffset? IssueDate { get; set; }
    public DateTimeOffset? DueDate { get; set; }
    public string? Notes { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}

public class InvoiceResponse
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public string? CustomerName { get; set; }
    public string? AccountName { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public InvoiceStatus Status { get; set; }
    public InvoiceType Type { get; set; }
    public DateTimeOffset IssueDate { get; set; }
    public DateTimeOffset DueDate { get; set; }
    public DateTimeOffset? PaidDate { get; set; }
    public decimal Subtotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal KalanTutar => TotalAmount - PaidAmount;
    public string? Notes { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
    public IReadOnlyList<InvoiceLineItemResponse> LineItems { get; set; } = Array.Empty<InvoiceLineItemResponse>();
}

public class InvoiceLineItemResponse
{
    public Guid Id { get; set; }
    public int LineNumber { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ProductCode { get; set; }
    public decimal Quantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public decimal TaxRate { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal LineTotal { get; set; }
}

public class InvoiceListItemResponse
{
    public Guid Id { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public string? AccountName { get; set; }
    public InvoiceStatus Status { get; set; }
    public InvoiceType Type { get; set; }
    public DateTimeOffset IssueDate { get; set; }
    public DateTimeOffset DueDate { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal KalanTutar => TotalAmount - PaidAmount;
}

public class PagedInvoiceResponse
{
    public IReadOnlyList<InvoiceListItemResponse> Items { get; set; } = Array.Empty<InvoiceListItemResponse>();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
}

// ==================== Payment DTOs ====================

public class CreatePaymentRequest
{
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public Guid? InvoiceId { get; set; }
    public string PaymentNumber { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public PaymentMethod Method { get; set; }
    public DateTimeOffset PaymentDate { get; set; }
    public string? ReferenceNumber { get; set; }
    public string? Notes { get; set; }
    public Guid? BranchId { get; set; }
}

public class UpdatePaymentRequest
{
    public Guid Id { get; set; }
    public string? PaymentNumber { get; set; }
    public PaymentMethod? Method { get; set; }
    public PaymentStatus? Status { get; set; }
    public decimal? Amount { get; set; }
    public string? ReferenceNumber { get; set; }
    public string? Notes { get; set; }
    public DateTimeOffset? PaymentDate { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}

public class PaymentResponse
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid AccountId { get; set; }
    public Guid CustomerId { get; set; }
    public string? AccountName { get; set; }
    public Guid? InvoiceId { get; set; }
    public string? InvoiceNumber { get; set; }
    public string PaymentNumber { get; set; } = string.Empty;
    public PaymentMethod Method { get; set; }
    public PaymentStatus Status { get; set; }
    public decimal Amount { get; set; }
    public decimal FeeAmount { get; set; }
    public decimal NetAmount { get; set; }
    public string? ReferenceNumber { get; set; }
    public string? Notes { get; set; }
    public DateTimeOffset PaymentDate { get; set; }
    public DateTimeOffset? ProcessedAtUtc { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}

public class PaymentListItemResponse
{
    public Guid Id { get; set; }
    public string PaymentNumber { get; set; } = string.Empty;
    public string? AccountName { get; set; }
    public string? InvoiceNumber { get; set; }
    public PaymentMethod Method { get; set; }
    public PaymentStatus Status { get; set; }
    public decimal Amount { get; set; }
    public DateTimeOffset PaymentDate { get; set; }
}

public class PagedPaymentResponse
{
    public IReadOnlyList<PaymentListItemResponse> Items { get; set; } = Array.Empty<PaymentListItemResponse>();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
}
