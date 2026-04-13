using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.DTO;

public sealed record ConvertTicketDto(TechnicianInfo? TechnicianInfo, OperationPriority priority, OperationType operationType, string? InternalNote);
