using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Account.Services;

namespace TechSupport.Account.Api.Controllers;

[ApiController]
[Route("api/accounts")]
public sealed class AccountsController : ControllerBase
{
    private readonly IAccountService _accounts;

    public AccountsController(IAccountService accounts)
    {
        _accounts = accounts;
    }

    [Authorize]
    [HttpGet("quick-sales")]
    public async Task<IActionResult> GetQuickSaleEntries(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var result = await _accounts.GetQuickSaleEntriesAsync(tenantId.Value, ct);
        return Ok(result.Select(x => new
        {
            x.Id,
            x.QuickSaleId,
            x.EntryNumber,
            entryType = x.EntryType.ToString(),
            x.GrossAmount,
            x.DiscountAmount,
            x.NetAmount,
            x.Currency,
            x.PaymentMethod,
            x.Description,
            x.CreatedAtUtc
        }));
    }

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }
}
