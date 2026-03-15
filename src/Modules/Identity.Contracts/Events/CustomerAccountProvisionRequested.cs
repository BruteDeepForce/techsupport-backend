namespace TechSupport.Identity.Contracts.Events;

public sealed record CustomerAccountProvisionRequested(
    Guid CorrelationId,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string Email,
    string? PhoneNumber,
    string TemporaryPassword);