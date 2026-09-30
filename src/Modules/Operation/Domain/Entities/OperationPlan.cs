using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Domain.Entities
{
    public class PlannedOperation
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public DateTimeOffset ScheduledAtUtc { get; set; }

        public Guid ToTechnicianUserId { get; set; }
        public string TechnicianFullName { get; set; } = string.Empty;

        public Guid? CustomerId {get; set;}
        public string CustomerName {get; set;} = string.Empty;

        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;

        public Guid OperationRecordId { get; set; }
        public OperationRecord OperationRecord { get; set; } = null!;

    }
}
