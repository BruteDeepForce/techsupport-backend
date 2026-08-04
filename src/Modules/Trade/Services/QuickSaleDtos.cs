using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Services;

public sealed record CreateQuickSaleLineRequest(Guid StockItemId, long Quantity);

public sealed record CreateQuickSaleRequest(
    Guid TenantId,
    Guid BranchId,
    Guid CreatedByUserId,
    string IdempotencyKey,
    QuickSalePaymentMethod PaymentMethod,
    decimal DiscountAmount,
    decimal? PaidAmount,
    IReadOnlyList<CreateQuickSaleLineRequest> Items);

public sealed record QuickSaleListRequest(int Page = 1, int PageSize = 20);
