namespace TechSupport.Trade.SignalR;

public interface ITradeStatusHub
{
    Task SendTradeStatusUpdate(Guid tenantId, Guid tradeId, string status);
}
