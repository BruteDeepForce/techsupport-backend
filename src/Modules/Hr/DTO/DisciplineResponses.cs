namespace Modules.HR.DTO;

public sealed record DisciplineResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string Description,
    decimal PenaltyAmount,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);

public sealed record DisciplineEmployeeRecordResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid EmployeeId,
    Guid DisciplineId,
    string Description,
    DateTime IncidentDate,
    DateTime CreatedAtUtc);
