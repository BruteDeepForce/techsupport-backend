using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Stock.DTO
{
    public class StockTradeDTO
    {
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public Guid? CategoryId { get; set; }
        public Guid? DeviceId { get; set; }

        public string Name { get; set; } = string.Empty;
        public long Quantity { get; set; }
        public string Sku { get; set; } = string.Empty; //! unique  
        public string? ImeiOrSerial { get; set; } //! unique 
        public string? Barcode { get; set; } = string.Empty; //! unique 
        public decimal? UnitPrice { get; set; }


    
    }
}