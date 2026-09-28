using TechSupport.Identity.Data;

namespace TechSupport.Identity.Services;

public interface IBranchService
{
    Task<Branch> CreateDefaultBranchAsync(Guid tenantId, string? branchName, CancellationToken cancellationToken = default);
}
