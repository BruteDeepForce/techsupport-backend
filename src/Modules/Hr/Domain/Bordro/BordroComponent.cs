using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Modules.HR.Domain.Bordro
{
    public class BordroComponent
    {
        //! Sgk koduyla örneğin sgk işçi kesintisi gibi kalemler için snapshot 
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid BranchId { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public BordroKalemType Type { get; set; } = BordroKalemType.Other;
        public ICollection<BordroKalem> BordroKalems { get; set; } = new List<BordroKalem>();
    }
}