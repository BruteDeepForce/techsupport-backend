using Microsoft.AspNetCore.SignalR;
using TechSupport.Trade.SignalR;

namespace TechSupport.Trade.Services;

public sealed class TradeStatusNotifier : ITradeStatusHub
{
    private readonly IHubContext<TradeStatusHub> _hubContext;

    public TradeStatusNotifier(IHubContext<TradeStatusHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public Task SendTradeStatusUpdate(Guid tenantId, Guid tradeId, string status)
    {
        return _hubContext
            .Clients
            .Group($"{tradeId} - {tenantId}")
            .SendAsync("ReceiveTradeStatusUpdate", new { TradeId = tradeId, Status = status });
    }
}