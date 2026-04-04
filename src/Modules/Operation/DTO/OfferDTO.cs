namespace TechSupport.Operation.DTO
{
    public sealed record OfferDTO(
        Guid Id,
        Guid TenantId,
        Guid? BranchId,
        Guid OperationId,
        Guid TechnicianUserId,
        Guid? CustomerId,
        decimal Amount,
        string Currency,
        DateTime CreatedAt,
        IEnumerable<OfferItemDTO> Items);
    public sealed record OfferItemDTO(
        Guid StockItemId,
        int Quantity,
        decimal UnitPrice);
}