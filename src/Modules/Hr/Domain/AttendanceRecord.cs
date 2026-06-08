namespace Modules.HR.Domain;

public enum AttendanceStatus
{
    OnTime = 1,
    Late = 2,
    EarlyLeave = 3,
    Absent = 4
}

public class AttendanceRecord
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid ShiftAssignmentId { get; set; }
    public DateTime ShiftDate { get; set; }
    public DateTime PlannedStartTimeUtc { get; set; }
    public DateTime PlannedEndTimeUtc { get; set; }
    public DateTime? CheckInTimeUtc { get; set; }
    public DateTime? CheckOutTimeUtc { get; set; }
    public AttendanceStatus Status { get; set; } = AttendanceStatus.OnTime;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
