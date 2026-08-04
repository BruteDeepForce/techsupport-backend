using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class Position
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        
        // public Guid BranchId { get; set; } //! kararsızım branch bazında pozisyon olabilir mi?
        public string Name { get; set; } = null!;
        public bool IsActive { get; set; } = true;
        public string? Description { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }

        public ICollection<Employee> Employees { get; set; } = new List<Employee>();
    }
}









