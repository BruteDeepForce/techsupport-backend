using System;
using System.Collections.Generic;
using TechSupport.Technician.Contracts.AI;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Contracts.AI
{
    public interface IQueryTechnician
    {
        Task<IReadOnlyCollection<TechnicianInfoResponse>> QueryTechniciansAsync(Guid tenantId, Guid? branchId, CancellationToken ct); 
    }
}