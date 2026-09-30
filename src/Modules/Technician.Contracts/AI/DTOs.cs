using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Contracts.AI
{
    public sealed record TechnicianInfoResponse(Guid TechnicianId, string Name, List<string> Specialty);
}