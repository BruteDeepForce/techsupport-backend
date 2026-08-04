using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Modules.HR.Domain.Bordro;

namespace Modules.HR.Domain
{
    public class Department
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        
        // public Guid BranchId { get; set; } //! kararsızım branch bazında departman olabilir mi?
        public string Name { get; set; } = null!;
        public string? Code { get; set; }
        public bool IsActive { get; set; } = true;
        public string? Description { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
        public ICollection<Employee> Employees { get; set; } = new List<Employee>();
        public ICollection<BordroDonem> BordroDonems { get; set; } = new List<BordroDonem>();
        public ICollection<BordroEmployee> BordroEmployees { get; set; } = new List<BordroEmployee>();
    }
}