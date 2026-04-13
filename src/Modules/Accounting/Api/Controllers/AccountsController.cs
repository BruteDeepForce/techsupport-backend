using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Accounting.Services;

namespace TechSupport.Accounting.Api.Controllers;

[ApiController]
[Route("api/accounting/accounts")]
[Authorize]
public class AccountsController : ControllerBase
{
    private readonly IAccountService _accountService;

    public AccountsController(IAccountService accountService)
    {
        _accountService = accountService;
    }

    [HttpGet("{accountId:guid}")]
    public async Task<ActionResult<AccountResponse>> GetById(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var account = await _accountService.GetByIdAsync(tenantId, accountId);
        if (account == null)
            return NotFound();

        return Ok(MapToResponse(account));
    }

    [HttpGet("by-number/{accountNumber}")]
    public async Task<ActionResult<AccountResponse>> GetByNumber(string accountNumber)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var account = await _accountService.GetByNumberAsync(tenantId, accountNumber);
        if (account == null)
            return NotFound();

        return Ok(MapToResponse(account));
    }

    [HttpGet]
    public async Task<ActionResult<PagedAccountResponse>> List(
        [FromQuery] AccountType? type = null,
        [FromQuery] AccountStatus? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _accountService.ListAsync(tenantId, type, status, page, pageSize);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<AccountResponse>> Create([FromBody] CreateAccountRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var account = await _accountService.CreateAsync(tenantId, request, User.Identity?.Name);
            return CreatedAtAction(nameof(GetById), new { accountId = account.Id }, MapToResponse(account));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPut("{accountId:guid}")]
    public async Task<ActionResult<AccountResponse>> Update(Guid accountId, [FromBody] UpdateAccountRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            // Ensure the request contains the correct Id
            request.Id = accountId;
            var account = await _accountService.UpdateAsync(tenantId, request, User.Identity?.Name);
            if (account == null)
                return NotFound();

            return Ok(MapToResponse(account));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{accountId:guid}")]
    public async Task<IActionResult> Delete(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _accountService.DeleteAsync(tenantId, accountId);
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpPost("{accountId:guid}/suspend")]
    public async Task<IActionResult> Suspend(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _accountService.SuspendAsync(tenantId, accountId);
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpPost("{accountId:guid}/activate")]
    public async Task<IActionResult> Activate(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _accountService.ActivateAsync(tenantId, accountId);
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpPost("{accountId:guid}/close")]
    public async Task<IActionResult> Close(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _accountService.CloseAsync(tenantId, accountId);
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpGet("{accountId:guid}/balance")]
    public async Task<ActionResult<decimal>> GetBalance(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var balance = await _accountService.GetBalanceAsync(tenantId, accountId);
        return Ok(balance);
    }

    private Guid GetTenantIdFromClaims()
    {
        var tenantIdClaim = User.FindFirst("tenantId") 
            ?? User.FindFirst("tenant_id");
        return tenantIdClaim != null ? Guid.Parse(tenantIdClaim.Value) : Guid.Empty;
    }

    private Guid? GetBranchIdFromClaims()
    {
        var branchIdClaim = User.FindFirst("branchId") 
            ?? User.FindFirst("branch_id");
        return branchIdClaim != null ? Guid.Parse(branchIdClaim.Value) : null;
    }

    private static AccountResponse MapToResponse(Account account)
    {
        return new AccountResponse
        {
            Id = account.Id,
            TenantId = account.TenantId,
            BranchId = account.BranchId,
            AccountNumber = account.AccountNumber,
            Name = account.Name,
            Description = account.Description,
            Type = account.Type,
            Status = account.Status,
            Balance = account.Balance,
            TotalBorc = account.TotalBorc,
            TotalAlacak = account.TotalAlacak,
            CreditLimit = account.CreditLimit,
            CreatedAtUtc = account.CreatedAtUtc,
            CreatedBy = account.CreatedBy,
            UpdatedAtUtc = account.UpdatedAtUtc,
            UpdatedBy = account.UpdatedBy
        };
    }
}
