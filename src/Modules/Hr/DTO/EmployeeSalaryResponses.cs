namespace Modules.HR.DTO;

public sealed record EmployeeSalaryResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid EmployeeId,
    decimal GrossSalary,
    decimal NetSalary,
    DateTime EffectiveFrom,
    DateTime? EffectiveTo,
    DateTime CreatedAtUtc);
