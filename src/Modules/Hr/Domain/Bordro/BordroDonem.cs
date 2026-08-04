using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain.Bordro
{
    public class BordroDonem
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public DateTime BaslangicTarihi { get; set; }
        public DateTime BitisTarihi { get; set; }
        public BordroPeriod Status { get; set; } = BordroPeriod.Open;
        public DateTime CreatedAtUtc { get; set; }
        public ICollection<BordroEmployee> BordroEmployees { get; set; } = new List<BordroEmployee>();
    }

    public enum BordroPeriod
    {
        Open = 1,
        Closed = 2
    }
}