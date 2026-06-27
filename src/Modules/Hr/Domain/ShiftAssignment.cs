using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class ShiftAssignment
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public Guid? ShiftTemplateId { get; set; }
        public ShiftTemplate? ShiftTemplate { get; set; }
        public DateTime PlannedStartTimeUtc { get; set; }
        public DateTime PlannedEndTimeUtc { get; set; }
        public DateTime? ActualStartTimeUtc { get; set; }
        public DateTime? ActualEndTimeUtc { get; set; }
        public ShiftAssignmentStatus Status { get; set; } = ShiftAssignmentStatus.Planned;
        public DateTime ShiftDate { get; set; } // Sadece tarih, saat bilgisi ShiftTemplate'den alınacak
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
    }

    public enum ShiftAssignmentStatus
    {
        Planned = 1,
        CheckedIn = 2,
        CheckedOut = 3,
        Completed = 4,
        Cancelled = 5
    }
}