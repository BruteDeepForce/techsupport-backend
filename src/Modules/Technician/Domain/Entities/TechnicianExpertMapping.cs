using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Domain.Entities
{
    public class TechnicianExpertMapping
    {
        public Guid TechnicianId { get; set; }
        public Guid tenantId { get; set; }
        public Guid? BranchId { get; set; }
        public Technician Technician { get; set; } = null!;
        public Guid TechnicianExpertId { get; set; }
        public TechnicianExpert TechnicianExpert { get; set; } = null!;
        public int? Level { get; set; } 
    }
}