using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Identity.Services
{
    public interface ITenantService
    {
        Task<Guid> CreateTenantAsync(string tenantName, CancellationToken cancellationToken);
        
    }
}