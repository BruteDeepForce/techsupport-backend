namespace Modules.HR.DTO;

public sealed record CreateEmployeeSalaryRequest(
    Guid BranchId,
    Guid EmployeeId,
    decimal GrossSalary,
    decimal NetSalary,
    DateTime EffectiveFrom,
    DateTime? EffectiveTo);

public sealed record UpdateEmployeeSalaryRequest(
    decimal? GrossSalary,
    decimal? NetSalary,
    DateTime? EffectiveFrom,
    DateTime? EffectiveTo);
