using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain.Bordro
{
    public class BordroKalem
    {
        //! Bordo kalemlerinin tam merkezi yönetimi. Componente ilişkili ve Type ortak.
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public Guid BordroEmployeeId { get; set; }
        public BordroEmployee BordroEmployee { get; set; } = null!;
        public Guid BordroComponentId { get; set; }
        public BordroComponent BordroComponent { get; set; } = null!;
        public BordroKalemType Type { get; set; } = BordroKalemType.Other;
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; }

        public DateTime CreatedAtUtc { get; set; }

    }

    public enum BordroKalemType
    {
        Earnings = 1,
        Deductions = 2,
        Other = 3
    }
}