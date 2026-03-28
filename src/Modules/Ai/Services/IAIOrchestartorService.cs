using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Ai.Services
{
    public interface IAIOrchestartorService
    {
        Task<string> ChatAsync(string query, Guid tenantId);
    }
}