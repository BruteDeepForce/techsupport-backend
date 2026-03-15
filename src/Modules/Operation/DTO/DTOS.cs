
using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.DTO
{
    public sealed record ResponseOperation(Guid Id, Guid TenantId, Guid? BranchId, Guid CustomerId, Guid DeviceId, Guid? TechnicianUserId, string Title, string Description, string Status, OperationPriority Priority, DateTimeOffset OccurredAtUtc);

    public sealed record CreateOperationDto(Guid CustomerId, Guid DeviceId, Guid? ToTechnician, string Title, string Description, string? InternalNote, OperationPriority Priority);

    public sealed record UpdateOperationDto(string Title, string Description, Guid? ToTechnician, string? InternalNote);
    public sealed record UpdateOperationStatusDto(string Status);

}