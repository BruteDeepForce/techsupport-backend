using MassTransit;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using System.ComponentModel.DataAnnotations;
using TechSupport.Identity.Contracts.Events;
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
    private readonly IdentityDbContext _dbContext;
    private readonly ITenantService _tenantService;
    private readonly IBus _bus;
    private readonly IPasswordResetService _passwordResetService;

    public AccountController(UserManager<AppUser> userManager, SignInManager<AppUser> signInManager,
    RoleManager<AppRole> roleManager, ITokenService tokenService, IUserService userService,
    IdentityDbContext dbContext, ITenantService tenantService, IBus bus,
    IPasswordResetService passwordResetService)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _roleManager = roleManager;
        _tokenService = tokenService;
        _userService = userService;
        _dbContext = dbContext;
        _bus = bus;
        _tenantService = tenantService;
        _passwordResetService = passwordResetService;
    }

    public record RegisterDto(string Email, string Password, string Role, string tenantName, Guid? BranchId);
    public record LoginDto(string Email, string Password);
    public sealed record ForgotPasswordDto([Required, EmailAddress] string Email);
    public sealed record ResetPasswordDto(
        [Required, EmailAddress] string Email,
        [Required, RegularExpression("^[0-9]{6}$")] string Code,
        [Required] string NewPassword);

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var user = new AppUser { UserName = dto.Email, Email = dto.Email };
        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded) return BadRequest(result.Errors);

        var role = await _roleManager.FindByNameAsync(dto.Role);
        if (role == null) return BadRequest($"Role '{dto.Role}' does not exist");

        await _userManager.AddToRoleAsync(user, dto.Role);
        var tenantId = await _tenantService.CreateTenantAsync(dto.tenantName, CancellationToken.None);
        if (tenantId == Guid.Empty) return BadRequest("Failed to create tenant");
        await _userService.CreateAsync(user.Id, tenantId, dto.BranchId, dto.Email, dto.Role, CancellationToken.None);

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
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto, CancellationToken ct)
    {
        await _passwordResetService.RequestCodeAsync(dto.Email.Trim(), ct);
        return Accepted(new
        {
            message = "Bu e-posta sistemde kayıtlıysa parola sıfırlama kodu gönderildi."
        });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto, CancellationToken ct)
    {
        var result = await _passwordResetService.ResetPasswordAsync(
            dto.Email.Trim(), dto.Code, dto.NewPassword, ct);

        if (!result.Succeeded)
        {
            return BadRequest(new { errors = result.Errors.Select(x => x.Description) });
        }

        var user = await _userManager.FindByEmailAsync(dto.Email.Trim());
        if (user is null)
        {
            return BadRequest(new { errors = new[] { "Kullanıcı bulunamadı." } });
        }

        var token = await _tokenService.CreateTokenForUserAsync(user, ct);
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
    [HttpPost("create-tenant")]
    public async Task<IActionResult> CreateTenant([FromBody] string tenantName, CancellationToken ct)
    {
        var tenant = new Tenant { Name = tenantName };
        await _dbContext.Tenants.AddAsync(tenant, ct);
        await _dbContext.SaveChangesAsync(ct);

        await _bus.Publish(new TenantCreated(tenant.Id, tenant.Name, DateTimeOffset.UtcNow), ct);
        return Ok(new { tenantId = tenant.Id });
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
