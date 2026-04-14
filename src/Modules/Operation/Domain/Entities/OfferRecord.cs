using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Domain.Entities
{
    public class OfferRecord
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public Guid OperationId { get; set; }
        public Guid TechnicianUserId { get; set; }
        public Guid? CustomerId { get; set; }
        public decimal Amount { get; set; }
        public decimal LaborAmount { get; set; }
        public OfferStatus Status { get; set; } = OfferStatus.Pending;
        public string Currency { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public ICollection<OfferRecordItem> Items { get; set; } = new List<OfferRecordItem>();
    }
    public enum OfferStatus
    {
        Pending,
        AdminApproved,
        CustomerApproved,
        AdminRejected,
        CustomerRejected
    }
}
