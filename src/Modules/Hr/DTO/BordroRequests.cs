using Modules.HR.Domain.Bordro;

namespace Modules.HR.DTO;

public sealed record CreateBordroDonemRequest(
    Guid BranchId,
    int Year,
    int Month,
    DateTime BaslangicTarihi,
    DateTime BitisTarihi);

public sealed record UpdateBordroDonemStatusRequest(
    BordroPeriod Status);

public sealed record CreateBordroKalemRequest(
    Guid BordroEmployeeId,
    Guid BordroComponentId,
    decimal Amount,
    string? Description,
    BordroKalemType? Type);
