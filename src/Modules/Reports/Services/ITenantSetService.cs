using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Identity.Contracts.Events;

namespace Reports.Services
{
    public interface ITenantSetService
    {
        Task HandleTenantCreatedAsync(TenantCreated message, CancellationToken ct);
        
    }
}