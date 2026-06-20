using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace TechSupport.Hr.SignalR
{
    public class HRNotificationHub : Microsoft.AspNetCore.SignalR.Hub
    {
        private readonly ILogger<HRNotificationHub> _logger;

        public HRNotificationHub(ILogger<HRNotificationHub> logger)
        {
            _logger = logger;
        }
        public async Task JoinPersonalNotification()
        {
            var tenantid = Context.User?.Claims.FirstOrDefault(c => c.Type == "tenant_id")?.Value;
            var userId = Context.User?.Claims.FirstOrDefault(c => c.Type == "user_id")?.Value;
            var role = Context.User?.Claims.FirstOrDefault(c => c.Type == "role")?.Value;
            _logger.LogDebug("Client role: {role}", role);
            if(role == "Admin")
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"{tenantid}:admins");
            }
            else
            {
                _logger.LogWarning("Client TenantID and UserID: {tenantId}, {userId}", tenantid, userId);
                await Groups.AddToGroupAsync(Context.ConnectionId, $"user:{userId}-{tenantid}:users");
            }
        }
        public async Task LeavePersonalNotification()
        {
            var tenantid = Context.User?.Claims.FirstOrDefault(c => c.Type == "tenant_id")?.Value;
            var userId = Context.User?.Claims.FirstOrDefault(c => c.Type == "user_id")?.Value;
            var role = Context.User?.Claims.FirstOrDefault(c => c.Type == "role")?.Value;
            if(role == "Admin")
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"{tenantid}:admins");
            }
            else
            {
                _logger.LogWarning("Client TenantID and UserID: {tenantId}, {userId}", tenantid, userId);
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user:{userId}-{tenantid}:users");
            }
        }
    }
}