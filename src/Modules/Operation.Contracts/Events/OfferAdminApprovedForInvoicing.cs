namespace TechSupport.Operation.Contracts.Events;

public sealed record OfferAdminApprovedForInvoicing(
    Guid OfferId,
    Guid OperationId,
    Guid TenantId,
    Guid? BranchId,
    Guid CustomerId,
    string Currency,
    decimal PartsAmount,
    decimal LaborAmount,
    decimal TotalAmount,
    IReadOnlyList<OfferAdminApprovedItem> Items,
    DateTimeOffset OccurredAtUtc);

public sealed record OfferAdminApprovedItem(
    Guid StockItemId,
    int Quantity,
    decimal UnitPrice,
    string Name);
