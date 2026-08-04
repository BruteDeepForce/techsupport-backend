using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Customer.Contracts.Events
{
    public class TradeDeviceUpdateRequest
    {
           public  Guid TradeId { get; set; }
            public Guid TenantId { get; set; }
            public Guid? BranchId { get; set; }
            public Guid DeviceId { get; set; }
            public Guid? CustomerId { get; set; }
            public Guid? AppUserId { get; set; }
            public string IdempotencyKey { get; set; }
            public string Brand { get; set; }
            public string Model { get; set; }
            public string SerialNumber { get; set; }
            public string? ProblemDescription { get; set; }
            public int? GuaranteePeriod { get; set; }
            public DateTimeOffset? WarrantyStartAtUtc { get; set; }
            public string? BarcodeNumber { get; set; }
            public string? CustomerName { get; set; }
            public string Status { get; set; }
            public DateTimeOffset OccurredAtUtc { get; set; }
        
    }
}