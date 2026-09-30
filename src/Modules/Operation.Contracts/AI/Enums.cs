using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Contracts.AI
{
    public enum OpType
    {
        Repair,
        Maintenance,
        Guarantee
    }
    public enum OpPriority
    {
        Normal,
        High,
        Urgent
    }
}