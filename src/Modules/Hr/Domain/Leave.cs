using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class Leave
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid? DepartmentId { get; set; }
        public Department? Department { get; set; }
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public Guid? LeaveDeductionId { get; set; }
        public LeaveDeduction? LeaveDeduction { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public LeaveType Type { get; set; }
        public string Reason { get; set; } = string.Empty;
        public LeaveStatus Status { get; set; } = LeaveStatus.Pending;
        public Guid? ApprovedByUserId { get; set; }
        public DateTime? ApprovedAtUtc { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
        

    }
    public enum LeaveType
    {
        Vacation = 1,
        SickLeave = 2,
        PersonalLeave = 3,
        MaternityLeave = 4,
        PaternityLeave = 5,
        UnpaidLeave = 6
    }
    public enum LeaveStatus
    {
        Pending = 1,
        Approved = 2,
        Rejected = 3
    }
}