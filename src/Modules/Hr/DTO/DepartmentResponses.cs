namespace Modules.HR.DTO;

public sealed record DepartmentResponse(
    Guid Id,
    Guid TenantId,
    string Name,
    string? Code,
    string? Description,
    bool IsActive,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);
