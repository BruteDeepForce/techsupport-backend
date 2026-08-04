namespace Modules.HR.DTO;

public sealed record ShiftTemplateResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string Name,
    TimeSpan StartTime,
    TimeSpan EndTime,
    bool IsNightShift,
    bool IsActive,
    string? Description,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);
