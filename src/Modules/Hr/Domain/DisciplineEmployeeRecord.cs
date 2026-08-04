using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class DisciplineEmployeeRecord
    {
        public Guid Id { get; set;}
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public Guid DisciplineId { get; set; }
        public Discipline Discipline { get; set; } = null!;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAtUtc { get; set; }
        public DateTime IncidentDate { get; set; }
    }
}