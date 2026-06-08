namespace Modules.HR.DTO;

public sealed record CreateDepartmentRequest(
    string Name,
    string? Code,
    string? Description,
    bool? IsActive);

public sealed record UpdateDepartmentRequest(
    string? Name,
    string? Code,
    string? Description,
    bool? IsActive);
