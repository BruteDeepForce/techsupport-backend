using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain.Bordro
{
    public class BordroEmployee
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid? DepartmentId { get; set; }
        public Department? Department { get; set; }
        public Guid BordroDonemId { get; set; }
        public BordroDonem BordroDonem { get; set; } = null!;
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public string EmployeeName { get; set; } = string.Empty;
        public decimal TotalEarnings { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal NetPay { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public ICollection<BordroKalem> BordroKalems { get; set; } = new List<BordroKalem>();
    }
}
