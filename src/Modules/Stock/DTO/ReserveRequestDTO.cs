namespace TechSupport.Stock.DTO
{
    public sealed record ReserveRequestDTO(
        Guid TenantId,
        Guid StockItemId,
        Guid TechnicianUserId,
        Guid? OperationId,
        int Quantity,
        Guid? BranchId);
}