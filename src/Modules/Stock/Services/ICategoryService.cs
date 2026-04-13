using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Services
{
    public interface ICategoryService
    {
        Task<StockCategories> CreateAsync(Guid tenantId, Guid? branchId, string name, CancellationToken ct = default);
        Task<IEnumerable<StockCategories>> GetAllAsync(Guid tenantId, CancellationToken ct = default);
    }
}
