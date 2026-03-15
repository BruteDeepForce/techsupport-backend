namespace TechSupport.User.Contracts.Events;

public record UserCreated(Guid UserId, Guid TenantId, Guid BranchId, string Email, string Role);
