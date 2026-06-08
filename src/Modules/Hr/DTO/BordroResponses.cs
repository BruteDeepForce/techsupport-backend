using Modules.HR.Domain.Bordro;

namespace Modules.HR.DTO;

public sealed record BordroDonemResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    int Year,
    int Month,
    DateTime BaslangicTarihi,
    DateTime BitisTarihi,
    BordroPeriod Status,
    DateTime CreatedAtUtc);

public sealed record BordroEmployeeResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid DepartmentId,
    Guid BordroDonemId,
    Guid EmployeeId,
    string EmployeeName,
    decimal TotalEarnings,
    decimal TotalDeductions,
    decimal NetPay,
    DateTime CreatedAtUtc);

public sealed record BordroKalemResponse(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    Guid BordroEmployeeId,
    Guid BordroComponentId,
    BordroKalemType Type,
    string Description,
    decimal Amount,
    DateTime CreatedAtUtc);

public sealed record BordroEmployeeDetailResponse(
    BordroEmployeeResponse Employee,
    IReadOnlyCollection<BordroKalemResponse> Kalemler);
