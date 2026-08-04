using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Customer.Contracts.Events
{
    public class TradeCustomerDeviceMapCompleted
    {
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid DeviceId { get; set; }
        public string? SerialNumber { get; set; }
        public string? BarcodeNumber { get; set; }
        public string? ProblemDescription { get; set; }
        public string Model { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? Brand { get; set; }
        public bool IsActive { get; set; } = true;
        public int? GuaranteePeriod { get; set; } // in months
        public DateTimeOffset? WarrantyStartAtUtc { get; set; }
        public DateTimeOffset? WarrantyEndAtUtc { get; set; }
        public Guid TradeId { get; set; }
        public string IdempotencyKey { get; set; } = string.Empty;
        
    }
}