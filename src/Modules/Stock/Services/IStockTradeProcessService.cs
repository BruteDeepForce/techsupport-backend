using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Stock.DTO;

namespace TechSupport.Stock.Services
{
    public interface IStockTradeProcessService
    {
        Task<bool> BuyTradeProcessStockTradeAsync(StockTradeDTO trade, CancellationToken cancellationToken = default);

        Task<bool> SellTradeProcessStockTradeAsync(StockTradeDTO trade, CancellationToken cancellationToken = default);
    }
}