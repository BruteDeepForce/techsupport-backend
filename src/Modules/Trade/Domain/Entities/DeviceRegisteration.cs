using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Trade.Domain.Entities
{
    public class DeviceRegisteration
    {
        public Guid Id { get; set; }
        public Guid TradeId { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public Guid? CustomerId { get; set; }
        public string IdempotencyKey { get; set; } = string.Empty;
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string? ProblemDescription { get; set; }
        public int? GuaranteePeriod { get; set; }
        public DateTimeOffset? WarrantyStartAtUtc { get; set; }
        public string? BarcodeNumber { get; set; }
        public string? CustomerName { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTimeOffset OccurredAtUtc { get; set; }
        public DateTimeOffset? ProcessedAtUtc { get; set; }
        public Guid? CreatedDeviceId { get; set; }

        public TradeRecord? Trade { get; set; }
    }
}