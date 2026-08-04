using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Domain.Entities
{
    public class TechnicianExpert
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public string ExpertiseName { get; set; } = string.Empty;
        public ICollection<TechnicianExpertMapping> TechnicianExpertMappings { get; set; } = new List<TechnicianExpertMapping>();
    }
}