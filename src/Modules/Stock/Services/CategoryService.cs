using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly StockDbContext _db;

        public CategoryService(StockDbContext db)
        {
            _db = db;
        }

        public async Task<StockCategories> CreateAsync(Guid tenantId, Guid? branchId, string name, CancellationToken ct = default)
        {
            // check duplicate name for the same tenant with a single DB call to reduce roundtrips
            if (await _db.StockCategories.AnyAsync(x => x.TenantId == tenantId && x.Name == name, ct))
                throw new InvalidOperationException($"Category '{name}' already exists for tenant {tenantId}");

            var cat = new StockCategories
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                Name = name
            };

            _db.StockCategories.Add(cat);
            await _db.SaveChangesAsync(ct);
            return cat;
        }

        public async Task<IEnumerable<StockCategories>> GetAllAsync(Guid tenantId, CancellationToken ct = default)
        {
            return await _db.StockCategories.Where(x => x.TenantId == tenantId).ToListAsync(ct);
        }
    }
}
