using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.DTO;

namespace TechSupport.Trade.Services;

public interface ITradeService
{
    Task<TradeRecord> StartTradeAsync(Guid tenantId, Guid branchId, StartTradeRequest request, string idempotencyKey, CancellationToken cancellationToken = default);
    Task<TradeRecord?> GetByIdAsync(Guid tenantId, Guid tradeId, CancellationToken cancellationToken = default);

    Task<bool> StartDeviceCreateWithTradeAsync(Guid tenantId, Guid branchId, Guid customerId, 
    Guid customerAppUserId, Guid tradeId, string idempotencyKey, CancellationToken cancellationToken = default);
    
    Task<bool> AccountModuleInsertAfterMappingAsync(Guid tenantId, Guid branchId, Guid customerId, Guid tradeId, string idempotencyKey, CancellationToken cancellationToken = default);

    Task<TradeServiceResult<List<TradeResponse>>> GetTradesAsync(Guid tenantId, int page, int pageSize, CancellationToken cancellationToken = default);
}
