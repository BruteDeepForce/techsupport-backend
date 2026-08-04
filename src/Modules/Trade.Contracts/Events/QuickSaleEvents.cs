namespace TechSupport.Trade.Contracts.Events;

public sealed record QuickSaleRequestedItem(Guid StockItemId, long Quantity);

public sealed record QuickSalePricedItem(
    Guid StockItemId,
    string ProductName,
    string Sku,
    string? Barcode,
    long Quantity,
    decimal UnitPrice,
    decimal LineTotal);

public sealed record QuickSaleStockRequested(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    IReadOnlyList<QuickSaleRequestedItem> Items,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleStockSucceeded(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    IReadOnlyList<QuickSalePricedItem> Items,
    decimal Subtotal,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleStockFailed(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    string Reason,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleAccountingRequested(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    string SaleNumber,
    string PaymentMethod,
    decimal Subtotal,
    decimal DiscountAmount,
    decimal TotalAmount,
    decimal PaidAmount,
    IReadOnlyList<QuickSalePricedItem> Items,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleAccountingSucceeded(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    Guid InvoiceId,
    Guid? PaymentId,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleAccountingFailed(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    string Reason,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleStockReleaseRequested(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    string Reason,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleStockReleased(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    DateTimeOffset OccurredAtUtc);

public sealed record QuickSaleStockReleaseFailed(
    Guid MessageId,
    Guid CorrelationId,
    Guid QuickSaleId,
    Guid TenantId,
    Guid BranchId,
    string IdempotencyKey,
    string Reason,
    DateTimeOffset OccurredAtUtc);
