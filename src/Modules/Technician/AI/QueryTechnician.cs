using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Technician.Contracts.AI;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.AI
{
    public class QueryTechnician : IQueryTechnician
    {
        private readonly ITechnicianService _technicianService;

        public QueryTechnician(ITechnicianService technicianService)
        {
            _technicianService = technicianService;
        }
        public async Task<IReadOnlyCollection<TechnicianInfoResponse>> QueryTechniciansAsync(Guid tenantId, Guid? branchId, CancellationToken ct)
        {
            var technicians = await _technicianService.ListAsync(tenantId, ct);
            var response = technicians.Select(t => new TechnicianInfoResponse(t.UserId, t.Name, t.Specializations)).ToList();
            return response;
        }
    }
}