namespace Modules.HR.DTO;

public sealed record CreateDisciplineRequest(
    Guid? BranchId,
    string Description,
    decimal PenaltyAmount);

public sealed record UpdateDisciplineRequest(
    string? Description,
    decimal? PenaltyAmount);

public sealed record CreateDisciplineEmployeeRecordRequest(
    Guid? BranchId,
    Guid EmployeeId,
    Guid DisciplineId,
    string Description,
    DateTime IncidentDate);

public sealed record UpdateDisciplineEmployeeRecordRequest(
    Guid? DisciplineId,
    string? Description,
    DateTime? IncidentDate);
