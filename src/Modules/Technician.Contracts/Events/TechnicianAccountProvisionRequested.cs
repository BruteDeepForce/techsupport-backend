namespace TechSupport.Technician.Contracts.Events;

public sealed record TechnicianAccountProvisionRequested(
    Guid CorrelationId,
    Guid TenantId,
    Guid? BranchId,
    string FirstName,
    string LastName,
    string Email,
    string? PhoneNumber,
    string TemporaryPassword);
