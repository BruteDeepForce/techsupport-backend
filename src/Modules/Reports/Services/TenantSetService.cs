using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Services;

namespace Reports.Services
{
    public class TenantSetService : ITenantSetService
    {
        private readonly ReportSetStore _store;
        
        public TenantSetService(ReportSetStore store)
        {
            _store = store;
        }
        
        public async Task HandleTenantCreatedAsync(TenantCreated message, CancellationToken ct)
        {

            await _store.CreateTenantSummaryAsync(message.TenantId, message.Name, message.OccurredAtUtc, ct);
            
        }
    }
}