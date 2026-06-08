using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Customer.Contracts.Events
{
    public class TradeCustomerCreatedComplete
    {
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public Guid AppUserId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid TradeId {get;set;}
        public string TradeCorelationKey {get;set;} = string.Empty;
        public DateTimeOffset OccurredAtUtc { get; set; }
        
    }
}