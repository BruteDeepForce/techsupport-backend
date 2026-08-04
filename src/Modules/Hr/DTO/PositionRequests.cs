namespace Modules.HR.DTO;

public sealed record CreatePositionRequest(
    string Name,
    string? Description,
    bool? IsActive);

public sealed record UpdatePositionRequest(
    string? Name,
    string? Description,
    bool? IsActive);
