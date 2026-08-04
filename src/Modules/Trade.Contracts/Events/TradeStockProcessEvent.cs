using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Trade.Contracts.Events
{
    public class TradeStockProcessEvent
    {
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid CategoryId { get; set; }
        public Guid DeviceId { get; set; }
        public string Name { get; set; } = null!;
        public int Quantity { get; set; }
        public string Sku { get; set; } = null!;
        public string ImeiOrSerial { get; set; } = null!;
        public string Barcode { get; set; } = null!;
        public decimal? UnitPrice { get; set; }

        public string Type { get; set; } = null!;
    }
}