using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Device.Contracts.Events
{
    public class DeviceCustomerMapping
    {
        public Guid DeviceId { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid CustomerId { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? CustomerName { get; set; }
        public string? ProblemDescription { get; set; } = string.Empty;
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public int? GuaranteePeriod { get; set; } // in months
        public DateTimeOffset? WarrantyStartAtUtc { get; set; }
        public DateTimeOffset? WarrantyEndAtUtc { get; set; }
        public string? BarcodeNumber { get; set; }
        public DateTimeOffset? UpdatedAtUtc { get; set; }
        public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset? DeactivatedAtUtc { get; set; }
    }
}
