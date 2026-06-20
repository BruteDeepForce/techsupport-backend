using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Hr.SignalR
{
    public interface IHRNotificationHub
    {
        Task SendShiftCreateByAdmin(Guid tenantId, Guid userId, Guid shiftId, string status);        
    }
}