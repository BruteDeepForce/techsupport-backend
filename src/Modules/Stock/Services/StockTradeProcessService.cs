using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Stock.Data;
using TechSupport.Stock.DTO;
using Microsoft.EntityFrameworkCore;

namespace TechSupport.Stock.Services
{
    public class StockTradeProcessService : IStockTradeProcessService
    {
        private readonly StockDbContext _db;
        public StockTradeProcessService(StockDbContext db)
        {
            _db = db;
        }
        public async Task<bool> BuyTradeProcessStockTradeAsync(StockTradeDTO trade, CancellationToken cancellationToken = default)
        {
            if(trade.Quantity <= 0 || string.IsNullOrEmpty(trade.Sku) 
            || trade.CategoryId == Guid.Empty 
            || trade.TenantId == Guid.Empty 
            || string.IsNullOrEmpty(trade.ImeiOrSerial) 
            || string.IsNullOrEmpty(trade.Barcode))
                return false;

            var category = await _db.StockCategories.FirstOrDefaultAsync(c => c.Id == trade.CategoryId && c.TenantId == trade.TenantId, cancellationToken);
            if (category == null)
                return false;
            
            var checkExistingItem = await _db.StockItems.FirstOrDefaultAsync(i => i.TenantId == trade.TenantId && (i.Sku == trade.Sku 
            || i.ImeiOrSerial == trade.ImeiOrSerial || i.Barcode == trade.Barcode), cancellationToken);
            if (checkExistingItem != null)                return false;

            var itemId = Guid.NewGuid();
            var newItem = new Domain.Entities.StockItem
            {
                Id = itemId,
                TenantId = trade.TenantId,
                BranchId = trade.BranchId,
                CategoryId = trade.CategoryId,
                DeviceId = trade.DeviceId,
                Sku = trade.Sku,
                ImeiOrSerial = trade.ImeiOrSerial,
                Barcode = trade.Barcode,
                Name = trade.Name,
                UnitPrice = trade.UnitPrice ?? 0, 
                Balances = new List<Domain.Entities.StockBalance>
                {
                    new Domain.Entities.StockBalance
                    {
                        Id = Guid.NewGuid(),
                        TenantId = trade.TenantId,
                        BranchId = trade.BranchId,
                        StockItemId = itemId,
                        QuantityAvailable = trade.Quantity,
                        QuantityReserved = 0
                    }
                }
                
            };

            await _db.StockItems.AddAsync(newItem, cancellationToken);
            await _db.SaveChangesAsync(cancellationToken);
            return true;
              
        }
        public async Task<bool> SellTradeProcessStockTradeAsync(StockTradeDTO trade, CancellationToken cancellationToken = default)
        {
            if(trade.Quantity <= 0 
            || trade.TenantId == Guid.Empty 
            || string.IsNullOrEmpty(trade.ImeiOrSerial) 
            || string.IsNullOrEmpty(trade.Barcode))
                return false;

            var item = await _db.StockItems.Include(i => i.Balances)
                .FirstOrDefaultAsync(i => i.TenantId == trade.TenantId 
                && i.ImeiOrSerial == trade.ImeiOrSerial && i.Barcode == trade.Barcode 
                && i.DeviceId == trade.DeviceId, cancellationToken);
            
            if (item == null)
                return false;

            var balance = item.Balances.FirstOrDefault(b => b.TenantId == trade.TenantId && b.StockItemId == item.Id);
            if (balance == null || balance.QuantityAvailable < trade.Quantity)
                return false;

            balance.QuantityAvailable -= trade.Quantity;
            await _db.SaveChangesAsync(cancellationToken);
            return true;
        }
    }
}