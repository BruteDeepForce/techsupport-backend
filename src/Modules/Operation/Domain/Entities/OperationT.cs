using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Domain.Entities
{
    public class OperationT
    {
        //! iş emri tipleri kullanıcı kendi tanımlamak isteyebilir. 
        //! Daha sonra bunu ayrıca düşüneceğim
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public Guid? BranchId { get; set; }
        public string Name { get; set; }
        
    }
}