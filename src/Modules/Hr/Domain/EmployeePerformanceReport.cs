using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Modules.HR.Domain;

namespace TechSupport.Hr.Domain
{
    public class EmployeePerformanceReport
    {
        public Guid Id { get; set; }
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }

        public int Year { get; set; }
        public int Month { get; set; }

        public int TotalAssignedTasks { get; set; }

        public int TotalCompletedTasks { get; set; }

        public int TotalPendingTasks { get; set; }

        public int TotalOverdueTasks { get; set; }

        public int? TotalCompletedOnTime { get; set; }

        public int? TotalCompletedLate { get; set; }

        public int RewardCount { get; set; }

        public int PenaltyCount { get; set; }

        public int LeaveCount { get; set; }

        public int ShiftAttendanceCount { get; set; }

        public int NotJoinedShiftCount { get; set; }

        public int OvertimeCount { get; set; }

    }
}