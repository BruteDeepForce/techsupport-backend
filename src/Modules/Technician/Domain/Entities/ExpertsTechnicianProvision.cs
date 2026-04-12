using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Domain.Entities
{
    public class ExpertsTechnicianProvision
    {
        public Guid Id { get; set; } 
        public Guid? ExpertiseId { get; set; }
        public Guid? TechnicianProvisionRequestId { get; set; }
        public TechnicianProvisionRequest? TechnicianProvisionRequest { get; set; }
    }
}
