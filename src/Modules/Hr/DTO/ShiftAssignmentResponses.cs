using Modules.HR.Domain;

namespace Modules.HR.DTO;

public sealed record ShiftAssignmentResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid EmployeeId,
    Guid ShiftTemplateId,
    DateTime ShiftDate,
    DateTime PlannedStartTimeUtc,
    DateTime PlannedEndTimeUtc,
    DateTime? ActualStartTimeUtc,
    DateTime? ActualEndTimeUtc,
    ShiftAssignmentStatus Status,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);
