using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Identity.Data;
using TechSupport.Identity.Services;
using TechSupport.User.Services;

namespace TechSupport.Identity.Api.Controllers;

[ApiController]
[Route("api/identity/[controller]")]
public class AccountController : ControllerBase
{
    private readonly UserManager<AppUser> _userManager;
    private readonly SignInManager<AppUser> _signInManager;
    private readonly RoleManager<AppRole> _roleManager;
    private readonly ITokenService _tokenService;
    private readonly IUserService _userService;

    public AccountController(UserManager<AppUser> userManager, SignInManager<AppUser> signInManager, RoleManager<AppRole> roleManager, ITokenService tokenService, IUserService userService)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _roleManager = roleManager;
        _tokenService = tokenService;
        _userService = userService;
    }

    public record RegisterDto(string Email, string Password, string Role, Guid TenantId, Guid? BranchId);
    public record LoginDto(string Email, string Password);

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var user = new AppUser { UserName = dto.Email, Email = dto.Email };
        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded) return BadRequest(result.Errors);

        var role = await _roleManager.FindByNameAsync(dto.Role);
        if (role == null) return BadRequest($"Role '{dto.Role}' does not exist");

        await _userManager.AddToRoleAsync(user, dto.Role);
        await _userService.CreateAsync(user.Id, dto.TenantId, dto.BranchId, dto.Email, dto.Role, CancellationToken.None);

        var token = await _tokenService.CreateTokenForUserAsync(user);

        return Ok(new { token });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user == null) return Unauthorized();

        var signInResult = await _signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        if (!signInResult.Succeeded) return Unauthorized();

        var token = await _tokenService.CreateTokenForUserAsync(user);

        return Ok(new { token });
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user == null) return NoContent();

        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        // In real app you'd email the token. For scaffold we return it.
        return Ok(new { token });
    }

    [Authorize(Roles = "admin")]
    [HttpPost("create-role")]
    public async Task<IActionResult> CreateRole([FromBody] string role)
    {
        var roleMgr = HttpContext.RequestServices.GetRequiredService<RoleManager<AppRole>>();
        var exists = await roleMgr.RoleExistsAsync(role);
        if (exists) return Conflict("Role exists");
        var r = new AppRole { Name = role };
        var res = await roleMgr.CreateAsync(r);
        if (!res.Succeeded) return BadRequest(res.Errors);
        return Ok(r);
    }

    [HttpPost("seed-role")]
    public async Task<IActionResult> SeedRole()
    {
        var roles = new[] { "admin", "customer", "technician" };
        foreach (var r in roles)
        {
            var exists = await _roleManager.RoleExistsAsync(r);
            if (!exists)
            {
                var res = await _roleManager.CreateAsync(new AppRole { Name = r });
                if (!res.Succeeded) return BadRequest(res.Errors);
            }
        }
        return Ok(roles);
    }
}
