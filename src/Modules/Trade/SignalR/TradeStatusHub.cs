using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace TechSupport.Trade.SignalR;

public class TradeStatusHub : Hub
{
    private readonly ILogger<TradeStatusHub> _logger;

    public TradeStatusHub(ILogger<TradeStatusHub> logger)
    {
        _logger = logger;
    }
    public async Task JoinTradeGroup(Guid tradeId)
    {
        var tenantid = Context.User?.Claims.FirstOrDefault(c => c.Type == "tenant_id")?.Value;

        _logger.LogWarning("Client TenantID: {tenantId}", tenantid);
        await Groups.AddToGroupAsync(Context.ConnectionId, $"{tradeId} - {tenantid}");
    }

    public async Task LeaveTradeGroup(Guid tradeId)
    {
        var tenantid = Context.User?.Claims.FirstOrDefault(c => c.Type == "tenant_id")?.Value;
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"{tradeId} - {tenantid}");
    }
}