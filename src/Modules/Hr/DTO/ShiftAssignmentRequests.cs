using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record CreateShiftAssignmentRequest(
    Guid BranchId,
    Guid EmployeeId,
    Guid ShiftTemplateId,
    DateTime ShiftDate,
    DateTime PlannedStartTimeUtc,
    DateTime PlannedEndTimeUtc);

public sealed record UpdateShiftAssignmentRequest(
    DateTime? PlannedStartTimeUtc,
    DateTime? PlannedEndTimeUtc,
    DateTime? ActualStartTimeUtc,
    DateTime? ActualEndTimeUtc,
    ShiftAssignmentStatus? Status);
