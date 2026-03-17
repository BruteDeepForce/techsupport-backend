using MassTransit;
using Microsoft.AspNetCore.Identity;
using TechSupport.Identity.Data;
using TechSupport.Technician.Contracts.Events;
using TechSupport.User.Services;

namespace TechSupport.Identity.Consumers;

public sealed class TechnicianAccountProvisionRequestedConsumer : IConsumer<TechnicianAccountProvisionRequested>
{
    private readonly UserManager<AppUser> _userManager;
    private readonly RoleManager<AppRole> _roleManager;
    private readonly IUserService _userService;

    public TechnicianAccountProvisionRequestedConsumer(UserManager<AppUser> userManager, RoleManager<AppRole> roleManager, IUserService userService)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _userService = userService;
    }

    public async Task Consume(ConsumeContext<TechnicianAccountProvisionRequested> context)
    {
        var message = context.Message;

        var existing = await _userManager.FindByEmailAsync(message.Email);
        if (existing is not null)
        {
            await context.Publish(new TechnicianAccountProvisionFailed(
                message.CorrelationId,
                message.Email,
                "Email already exists",
                DateTimeOffset.UtcNow));
            return;
        }

        if (!await _roleManager.RoleExistsAsync("technician"))
        {
            var roleResult = await _roleManager.CreateAsync(new AppRole { Name = "technician" });
            if (!roleResult.Succeeded)
            {
                await context.Publish(new TechnicianAccountProvisionFailed(
                    message.CorrelationId,
                    message.Email,
                    string.Join(", ", roleResult.Errors.Select(x => x.Description)),
                    DateTimeOffset.UtcNow));
                return;
            }
        }

        var user = new AppUser
        {
            UserName = message.Name,
            Email = message.Email
        };

        var createResult = await _userManager.CreateAsync(user, message.TemporaryPassword);
        if (!createResult.Succeeded)
        {
            await context.Publish(new TechnicianAccountProvisionFailed(
                message.CorrelationId,
                message.Email,
                string.Join(", ", createResult.Errors.Select(x => x.Description)),
                DateTimeOffset.UtcNow));
            return;
        }

        await _userManager.AddToRoleAsync(user, "technician");
        //await _userService.CreateAsync(user.Id, message.TenantId, message.BranchId, message.Email, "technician", context.CancellationToken);

        await context.Publish(new TechnicianAccountProvisioned(
            message.CorrelationId,
            user.Id,
            message.TenantId,
            message.BranchId,
            message.Name,
            message.Email,
            message.PhoneNumber,
            DateTimeOffset.UtcNow));
    }
}
