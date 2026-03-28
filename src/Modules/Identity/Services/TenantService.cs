using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TechSupport.Identity.Data;

namespace TechSupport.Identity.Services
{
    public class TenantService : ITenantService
    {
        private readonly TechSupport.Identity.Data.IdentityDbContext _dbContext;
        
        public TenantService(TechSupport.Identity.Data.IdentityDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<Guid> CreateTenantAsync(string tenantName, CancellationToken cancellationToken)
        {
            var tenant = new Tenant { Name = tenantName };
            if(await _dbContext.Tenants.AnyAsync(t => t.Name == tenantName, cancellationToken))
            {
                throw new InvalidOperationException($"Tenant with name '{tenantName}' already exists.");
            }
            await _dbContext.Tenants.AddAsync(tenant, cancellationToken);
            await _dbContext.SaveChangesAsync(cancellationToken);
            return tenant.Id;
        }
    }
}