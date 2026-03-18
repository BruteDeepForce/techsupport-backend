using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Reports.Domain.Enums;

namespace Reports.Domain.Entities
{
    public class TechnicianWork
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public Guid TechnicianId { get; set; }
        public Guid OperationId { get; set; }
        public WorkStatus Status { get; set; } = WorkStatus.Completed;
        public string OperationDescription { get; set; } = string.Empty;
        public DateTimeOffset AssignedAtUtc { get; set; }
        public DateTimeOffset? StartedAtUtc { get; set; }
        public DateTimeOffset? CompletedAtUtc { get; set; }
    }

}