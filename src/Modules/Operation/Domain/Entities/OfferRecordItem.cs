using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Domain.Entities
{
    public class OfferRecordItem
    {
        public Guid Id { get; set; }
        public Guid OfferRecordId { get; set; }
        public Guid StockItemId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public OfferRecord OfferRecord { get; set; } = null!;
    }
}