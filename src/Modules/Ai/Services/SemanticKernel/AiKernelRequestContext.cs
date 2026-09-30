namespace Ai.Services.SemanticKernel;

public sealed class AiKernelRequestContext
{
    public Guid TenantId { get; private set; }
    public Guid? BranchId { get; private set; }
    public Guid UserId { get; private set; }

    public void Set(Guid tenantId, Guid? branchId, Guid userId)
    {
        TenantId = tenantId;
        BranchId = branchId;
        UserId = userId;
    }
}
