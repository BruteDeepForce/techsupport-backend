using MassTransit;
using Microsoft.AspNetCore.Identity;
using TechSupport.Identity.Data;
using TechSupport.Identity.Contracts.Events;
using TechSupport.User.Services;

namespace TechSupport.Identity.Consumers;

public sealed class CustomerAccountProvisionRequestedConsumer : IConsumer<CustomerAccountProvisionRequested>
{
    private readonly UserManager<AppUser> _userManager;
    private readonly RoleManager<AppRole> _roleManager;
    private readonly IUserService _userService;

    public CustomerAccountProvisionRequestedConsumer(UserManager<AppUser> userManager, RoleManager<AppRole> roleManager, IUserService userService)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _userService = userService;
    }

    public async Task Consume(ConsumeContext<CustomerAccountProvisionRequested> context)
    {
        var message = context.Message;

        var ApiKey = "12345678"; // Generate a secure temporary password in production

        var existing = await _userManager.FindByEmailAsync(message.Email);
        if (existing is not null)
        {
            await context.Publish(new CustomerAccountProvisionFailed(
                message.CorrelationId,
                message.Email,
                "Email already exists",
                DateTimeOffset.UtcNow));
            return;
        }

        if (!await _roleManager.RoleExistsAsync("customer"))
        {
            var roleResult = await _roleManager.CreateAsync(new AppRole { Name = "customer" });
            if (!roleResult.Succeeded)
            {
                await context.Publish(new CustomerAccountProvisionFailed(
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
            await context.Publish(new CustomerAccountProvisionFailed(
                message.CorrelationId,
                message.Email,
                string.Join(", ", createResult.Errors.Select(x => x.Description)),
                DateTimeOffset.UtcNow));
            return;
        }

        await _userManager.AddToRoleAsync(user, "customer");
        await _userService.CreateAsync(user.Id, message.TenantId, message.BranchId, message.Email, "customer", context.CancellationToken);

        await context.Publish(new CustomerAccountProvisioned(
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