using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.DTO;

public sealed record CreateTicketDto(Guid? DeviceId, string Title, string Description, Priority? Priority);
