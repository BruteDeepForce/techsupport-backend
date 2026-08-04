using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class Discipline
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal PenaltyAmount { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime UpdatedAtUtc { get; set; }

        public ICollection<DisciplineEmployeeRecord> DisciplineEmployeeRecords { get; set; } = new List<DisciplineEmployeeRecord>();
    }
}