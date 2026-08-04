using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using TechSupport.Hr.SignalR;

namespace TechSupport.Hr.Application
{
    public class ShiftStatusNotifier : IHRNotificationHub
    {
        private readonly IHubContext<HRNotificationHub> _hubContext;

        public ShiftStatusNotifier(IHubContext<HRNotificationHub> hubContext)
        {
            _hubContext = hubContext;
        }
        public  Task SendShiftCreateByAdmin(Guid tenantId, Guid userId, Guid shiftId, string status)
        {
            return _hubContext
                .Clients
                .Group($"user:{userId}-{tenantId}:users")
                .SendAsync("ReceiveShiftCreateByAdmin", new { ShiftId = shiftId, Status = status });
        }
    }
}