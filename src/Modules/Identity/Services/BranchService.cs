using Microsoft.EntityFrameworkCore;
using TechSupport.Identity.Data;

namespace TechSupport.Identity.Services;

public sealed class BranchService : IBranchService
{
    private const string DefaultBranchName = "Merkez";

    private readonly IdentityDbContext _dbContext;

    public BranchService(IdentityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Branch> CreateDefaultBranchAsync(Guid tenantId, string? branchName, CancellationToken cancellationToken = default)
    {
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        var tenantExists = await _dbContext.Tenants.AnyAsync(x => x.Id == tenantId, cancellationToken);
        if (!tenantExists)
            throw new InvalidOperationException($"Tenant '{tenantId}' does not exist.");

        var normalizedBranchName = string.IsNullOrWhiteSpace(branchName)
            ? DefaultBranchName
            : branchName.Trim();

        var existingBranch = await _dbContext.Branches
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Name == normalizedBranchName, cancellationToken);
        if (existingBranch is not null)
            return existingBranch;

        var branch = new Branch
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = normalizedBranchName
        };

        await _dbContext.Branches.AddAsync(branch, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return branch;
    }
}
