using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.DTO;

public sealed record ConvertTicketDto(Guid? ToTechnician, OperationPriority priority, string? InternalNote);
