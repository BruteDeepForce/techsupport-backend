using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class LeaveDeduction
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public string Description { get; set; } = string.Empty;
        public LeaveType? DeductionType { get; set; }
        public DeductionPeriodForCalculation? DeductionPeriod { get; set; }
        public decimal DeductionAmount { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime UpdatedAtUtc { get; set; }
        public ICollection<Leave> Leaves { get; set; } = new List<Leave>();
    }
    public enum DeductionPeriodForCalculation
    {
        Daily = 1,
        Hourly = 2
    }

}