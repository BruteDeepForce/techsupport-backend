namespace Modules.HR.DTO;

public sealed record CreateShiftTemplateRequest(
    Guid BranchId,
    string Name,
    TimeSpan StartTime,
    TimeSpan EndTime,
    bool? IsNightShift,
    bool? IsActive,
    string? Description);

public sealed record UpdateShiftTemplateRequest(
    string? Name,
    TimeSpan? StartTime,
    TimeSpan? EndTime,
    bool? IsNightShift,
    bool? IsActive,
    string? Description);
