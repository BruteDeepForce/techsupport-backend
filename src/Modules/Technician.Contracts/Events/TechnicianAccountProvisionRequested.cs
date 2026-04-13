namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianAccountProvisionRequested(
    Guid CorrelationId,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string Email,
    string? PhoneNumber,
    string TemporaryPassword);
