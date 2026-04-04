using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.DTO
{
    public class TechnicianResponseDTO
    {
        public Guid TenantId { get; set; }
        public Guid UserId { get; set; }
        public string Name { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string PhoneNumber { get; set; } = null!;
        public bool IsActive { get; set; }
        public List<string> Specializations { get; set; } = new List<string>();
    }
}