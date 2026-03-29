using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Contracts.Events
{
    public class OperationStatusAIEvent
    {
        public Guid CorrelationId { get; set; }
        public Guid OperationId { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string? TechnicianInfo { get; set; }
        public string? CustomerInfo { get; set; }
        public string Status { get; set; } 
        public DateTimeOffset? CreatedAtUtc { get; set; }
        public DateTimeOffset? AssignedAtUtc { get; set; }
        public DateTimeOffset? EndedAtUtc { get; set; }
    }
}