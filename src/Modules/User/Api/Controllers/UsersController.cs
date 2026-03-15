using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.User.Services;

namespace TechSupport.User.Api.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    public record CreateUserDto(Guid TenantId, Guid? BranchId, string Email, string Role, Guid? AppUserId);

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto, CancellationToken ct)
    {
        var appUserId = dto.AppUserId ?? Guid.NewGuid();
        var user = await _userService.CreateAsync(appUserId, dto.TenantId, dto.BranchId, dto.Email, dto.Role, ct);
        return Ok(new { user.Id, user.TenantId, user.BranchId, user.Email, user.Role });
    }
}
