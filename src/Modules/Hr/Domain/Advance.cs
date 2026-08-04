using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain
{
    public class Advance
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid DepartmentId { get; set; }
        public Department Department { get; set; } = null!;
        public Guid EmployeeId { get; set; }
        public Employee Employee { get; set; } = null!;
        public decimal Amount { get; set; }
        public string Reason { get; set; } = string.Empty;
        public AdvanceStatus Status { get; set; } = AdvanceStatus.Pending;
        public Guid? ApprovedByUserId { get; set; }
        public DateTime? ApprovedAtUtc { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
    }
    public enum AdvanceStatus
    {
        Pending = 1,
        Approved = 2,
        Rejected = 3
    }

    //! taksit olacak mı bilgisi
    //! HR Advance settings kurulacak ve maksimum taksit sayısı ve avans limiti ve avans tarih aralığı bilgileri tutulacak
    //! leave settings oluşturalım ve maksimum izin limiti bulunduralım. ücretsiz izinlerin yıllık izinden düşüp düşmeyeceği bilgisi tutalım.
    
}