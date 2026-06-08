using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Trade.DTO
{
    public class TradeResponse
    {
        public Guid TradeId { get; set; }
        public Guid CustomerId { get; set; }
        public string CustomerName { get; set; } 
        public Guid DeviceId { get; set; }

        public string DeviceName { get; set; }
        public DateTime CreatedAt { get; set; }
        public string PaymentMethod { get; set; }

        public string Type { get; set; }

        public decimal TotalAmount { get; set; }

        public string Status { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }

        public int ExistingCount { get; set; }
    }
}