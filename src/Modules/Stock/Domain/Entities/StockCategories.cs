using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Stock.Domain.Entities
{
    public class StockCategories
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public string Name { get; set; } = string.Empty;
        public ICollection<StockItem> StockItems { get; set; } = new List<StockItem>();
        
    }
}