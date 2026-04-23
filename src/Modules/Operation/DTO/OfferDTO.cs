using TechSupport.Operation.Domain.Entities;

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
        decimal LaborAmount,
        string Currency,
        DateTime CreatedAt,
        OfferStatus? Status,
        IEnumerable<OfferItemDTO> Items);
    public sealed record OfferItemDTO(
        Guid StockItemId,
        string Name,
        int Quantity,
        decimal UnitPrice);
}
