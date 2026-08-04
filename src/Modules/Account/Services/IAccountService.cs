using TechSupport.Account.Domain.Entities;

namespace TechSupport.Account.Services;

public interface IAccountService
{
    Task<QuickSaleAccountEntry> CreateQuickSaleEntryAsync(CreateQuickSaleAccountEntryRequest request, CancellationToken ct = default);
    Task<IReadOnlyList<QuickSaleAccountEntry>> GetQuickSaleEntriesAsync(Guid tenantId, CancellationToken ct = default);
}
