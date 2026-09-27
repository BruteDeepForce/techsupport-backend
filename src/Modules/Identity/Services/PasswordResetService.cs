using System.Globalization;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TechSupport.Identity.Data;

namespace TechSupport.Identity.Services;

public interface IPasswordResetService
{
    Task RequestCodeAsync(string email, CancellationToken ct);
    Task<IdentityResult> ResetPasswordAsync(string email, string code, string newPassword, CancellationToken ct);
}

public sealed class PasswordResetService : IPasswordResetService
{
    private readonly IdentityDbContext _dbContext;
    private readonly UserManager<AppUser> _userManager;
    private readonly IPasswordHasher<PasswordResetCode> _codeHasher;
    private readonly IPasswordResetEmailSender _emailSender;
    private readonly int _codeLifetimeMinutes;
    private readonly int _maxAttempts;
    private readonly int _minimumRequestIntervalSeconds;
    private readonly ILogger<PasswordResetService> _logger;

    public PasswordResetService(
        IdentityDbContext dbContext,
        UserManager<AppUser> userManager,
        IPasswordHasher<PasswordResetCode> codeHasher,
        IPasswordResetEmailSender emailSender,
        IConfiguration configuration,
        ILogger<PasswordResetService> logger)
    {
        _dbContext = dbContext;
        _userManager = userManager;
        _codeHasher = codeHasher;
        _emailSender = emailSender;
        _codeLifetimeMinutes = configuration.GetValue<int?>("PasswordReset:CodeLifetimeMinutes") ?? 10;
        _maxAttempts = configuration.GetValue<int?>("PasswordReset:MaxAttempts") ?? 5;
        _minimumRequestIntervalSeconds = configuration.GetValue<int?>("PasswordReset:MinimumRequestIntervalSeconds") ?? 60;
        _logger = logger;
    }

    public async Task RequestCodeAsync(string email, CancellationToken ct)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user is null)
        {
            // Keep some password-hashing work on the unknown-account path.
            _ = _codeHasher.HashPassword(new PasswordResetCode(), "000000");
            return;
        }

        var now = DateTimeOffset.UtcNow;
        var mostRecent = await _dbContext.PasswordResetCodes
            .Where(x => x.UserId == user.Id)
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (mostRecent is not null &&
            mostRecent.CreatedAtUtc.AddSeconds(_minimumRequestIntervalSeconds) > now)
        {
            return;
        }

        var activeCodes = await _dbContext.PasswordResetCodes
            .Where(x => x.UserId == user.Id && x.UsedAtUtc == null && x.ExpiresAtUtc > now)
            .ToListAsync(ct);
        foreach (var activeCode in activeCodes)
        {
            activeCode.UsedAtUtc = now;
        }

        var code = RandomNumberGenerator.GetInt32(0, 1_000_000)
            .ToString("D6", CultureInfo.InvariantCulture);
        var resetCode = new PasswordResetCode
        {
            UserId = user.Id,
            ExpiresAtUtc = now.AddMinutes(_codeLifetimeMinutes)
        };
        resetCode.CodeHash = _codeHasher.HashPassword(resetCode, code);

        _dbContext.PasswordResetCodes.Add(resetCode);
        await _dbContext.SaveChangesAsync(ct);

        try
        {
            await _emailSender.SendCodeAsync(user.Email!, code, _codeLifetimeMinutes, ct);
        }
        catch (Exception ex)
        {
            resetCode.UsedAtUtc = DateTimeOffset.UtcNow;
            await _dbContext.SaveChangesAsync(CancellationToken.None);
            _logger.LogError(ex, "Password reset email could not be sent for user {UserId}", user.Id);
        }
    }

    public async Task<IdentityResult> ResetPasswordAsync(
        string email,
        string code,
        string newPassword,
        CancellationToken ct)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user is null)
        {
            return InvalidCodeResult();
        }

        var now = DateTimeOffset.UtcNow;
        var resetCode = await _dbContext.PasswordResetCodes
            .Where(x => x.UserId == user.Id && x.UsedAtUtc == null)
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (resetCode is null || resetCode.ExpiresAtUtc <= now || resetCode.FailedAttempts >= _maxAttempts)
        {
            return InvalidCodeResult();
        }

        var verification = _codeHasher.VerifyHashedPassword(resetCode, resetCode.CodeHash, code);
        if (verification == PasswordVerificationResult.Failed)
        {
            resetCode.FailedAttempts++;
            if (resetCode.FailedAttempts >= _maxAttempts)
            {
                resetCode.UsedAtUtc = now;
            }

            await _dbContext.SaveChangesAsync(ct);
            return InvalidCodeResult();
        }

        // This is an internal ASP.NET Identity password-reset token, not a login JWT.
        // The user has already proved account ownership with the one-time email code.
        var identityPasswordResetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
        var result = await _userManager.ResetPasswordAsync(user, identityPasswordResetToken, newPassword);
        if (!result.Succeeded)
        {
            return result;
        }

        resetCode.UsedAtUtc = now;
        await _dbContext.SaveChangesAsync(ct);
        return IdentityResult.Success;
    }

    private static IdentityResult InvalidCodeResult() => IdentityResult.Failed(
        new IdentityError
        {
            Code = "InvalidPasswordResetCode",
            Description = "Kod geçersiz veya süresi dolmuş."
        });
}
