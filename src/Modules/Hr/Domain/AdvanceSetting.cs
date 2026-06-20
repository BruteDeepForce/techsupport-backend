using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Hr.Domain
{
    public class AdvanceSetting
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public decimal MaxAdvanceAmountPerPerson { get; set; }
        public int MaxAdvanceCountPerYear { get; set; }
        public bool AllowFutureAdvances { get; set; } = false;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
    }
}