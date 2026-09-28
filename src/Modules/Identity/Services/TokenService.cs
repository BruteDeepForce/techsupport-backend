using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using TechSupport.Identity.Data;
using TechSupport.User.Services;
using Microsoft.EntityFrameworkCore;

namespace TechSupport.Identity.Services;

public interface ITokenService
{
    string CreateToken(System.Security.Claims.ClaimsIdentity identity);
    Task<string> CreateTokenForUserAsync(AppUser user, CancellationToken ct = default);
}

public class TokenService : ITokenService
{
    private readonly IConfiguration _config;
    private readonly UserManager<AppUser> _userManager;
    private readonly IUserService _userService;
    private readonly IdentityDbContext _identityDbContext;

    public TokenService(IConfiguration config, UserManager<AppUser> userManager, IUserService userService, IdentityDbContext identityDbContext)
    {
        _config = config;
        _userManager = userManager;
        _userService = userService;
        _identityDbContext = identityDbContext;
    }

    public string CreateToken(ClaimsIdentity identity)
    {
        var key = _config["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key not set in configuration");
        var issuer = _config["Jwt:Issuer"] ?? "TechSupport";

        var creds = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)), SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: issuer,
            claims: identity.Claims,
            expires: DateTime.UtcNow.AddHours(6),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public async Task<string> CreateTokenForUserAsync(AppUser user, CancellationToken ct = default)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.UserName ?? string.Empty),
            new Claim("user_id", user.Id.ToString()),
            new Claim("username", user.UserName ?? string.Empty),
            new Claim("security_stamp", await _userManager.GetSecurityStampAsync(user))
        };

        var profile = await _userService.GetByAppUserIdAsync(user.Id, ct);
        if (profile is not null)
        {
            claims.Add(new Claim("tenant_id", profile.TenantId.ToString()));
            if (profile.BranchId.HasValue)
            {
                var branchName = await _identityDbContext.Branches
                    .AsNoTracking()
                    .Where(x => x.TenantId == profile.TenantId && x.Id == profile.BranchId.Value)
                    .Select(x => x.Name)
                    .FirstOrDefaultAsync(ct);

                claims.AddRange(new[]
                {
                    new Claim("branch_id", profile.BranchId.Value.ToString()),
                    new Claim("branch_name", branchName ?? string.Empty)
                });
            }
        }

        var roles = await _userManager.GetRolesAsync(user);
        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        return CreateToken(new ClaimsIdentity(claims));
    }
}
