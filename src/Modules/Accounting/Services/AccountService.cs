using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public class AccountService : IAccountService
{
    private readonly AccountingDbContext _db;

    public AccountService(AccountingDbContext db)
    {
        _db = db;
    }

    public async Task<Account?> GetByIdAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        return await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);
    }

    public async Task<Account?> GetByNumberAsync(Guid tenantId, string accountNumber, CancellationToken ct = default)
    {
        return await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.AccountNumber == accountNumber && x.TenantId == tenantId, ct);
    }

    /// <summary>
    /// Get account by customer ID - queries invoices to find the account
    /// </summary>
    public async Task<Account?> GetByCustomerIdAsync(Guid tenantId, Guid customerId, CancellationToken ct = default)
    {
        // Find an invoice for this customer to get the account
        var invoice = await _db.Invoices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.CustomerId == customerId)
            .FirstOrDefaultAsync(ct);

        if (invoice == null)
            return null;

        return await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == invoice.AccountId && x.TenantId == tenantId, ct);
    }

    public async Task<PagedAccountResponse> ListAsync(Guid tenantId, AccountType? type = null, AccountStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        var query = _db.Accounts
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (type.HasValue)
            query = query.Where(x => x.Type == type.Value);

        if (status.HasValue)
            query = query.Where(x => x.Status == status.Value);

        var totalCount = await query.CountAsync(ct);

        var items = await query
            .OrderBy(x => x.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new AccountListItemResponse
            {
                Id = x.Id,
                AccountNumber = x.AccountNumber,
                Name = x.Name,
                Type = x.Type,
                Status = x.Status,
                Balance = x.Balance,
                TotalBorc = x.TotalBorc,
                TotalAlacak = x.TotalAlacak,
                CreditLimit = x.CreditLimit,
                CreatedAtUtc = x.CreatedAtUtc
            })
            .ToListAsync(ct);

        return new PagedAccountResponse
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<Account> CreateAsync(Guid tenantId, CreateAccountRequest request, string? createdBy = null, CancellationToken ct = default)
    {
        // Enforce single account per tenant
        var tenantAccountExists = await _db.Accounts
            .AnyAsync(x => x.TenantId == tenantId, ct);

        if (tenantAccountExists)
            throw new InvalidOperationException("This tenant already has an account");

        // Check if account number already exists
        var exists = await _db.Accounts
            .AnyAsync(x => x.TenantId == tenantId && x.AccountNumber == request.AccountNumber, ct);
        
        if (exists)
            throw new InvalidOperationException($"Account number '{request.AccountNumber}' already exists");

        var account = new Account
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            Name = request.Name.Trim(),
            AccountNumber = request.AccountNumber.Trim(),
            Type = request.Type,
            Balance = 0,
            TotalBorc = 0,
            TotalAlacak = 0,
            CreditLimit = request.CreditLimit,
            Status = AccountStatus.Active,
            Description = request.Description?.Trim(),
            CreatedAtUtc = DateTimeOffset.UtcNow,
            CreatedBy = createdBy
        };

        await _db.Accounts.AddAsync(account, ct);
        await _db.SaveChangesAsync(ct);
        return account;
    }

    public async Task<Account?> UpdateAsync(Guid tenantId, UpdateAccountRequest request, string? updatedBy = null, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == request.Id && x.TenantId == tenantId, ct);

        if (account is null) return null;

        if(request.RowVersion == null)
            throw new InvalidOperationException("RowVersion is required for update to ensure data integrity");

        // Check RowVersion for optimistic concurrency
        _db.Entry(account).Property(x=> x.RowVersion).OriginalValue = request.RowVersion;

        if (!string.IsNullOrWhiteSpace(request.Name))
            account.Name = request.Name.Trim();

        if (!string.IsNullOrWhiteSpace(request.AccountNumber))
        {
            // Check if new account number is available
            if (request.AccountNumber != account.AccountNumber)
            {
                var numberExists = await _db.Accounts
                    .AnyAsync(x => x.TenantId == tenantId && x.AccountNumber == request.AccountNumber && x.Id != request.Id, ct);
                
                if (numberExists)
                    throw new InvalidOperationException($"Account number '{request.AccountNumber}' already exists");
                
                account.AccountNumber = request.AccountNumber.Trim();
            }
        }

        if (request.Type.HasValue)
            account.Type = request.Type.Value;

        if (request.CreditLimit.HasValue)
            account.CreditLimit = request.CreditLimit.Value;

        if (!string.IsNullOrWhiteSpace(request.Description))
            account.Description = request.Description.Trim();

        if (request.Status.HasValue)
            account.Status = request.Status.Value;

        account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        account.UpdatedBy = updatedBy;

        try
        {
            await _db.SaveChangesAsync(ct);
            return account;
        }
        catch (DbUpdateConcurrencyException)
        {
            // Re-fetch to check if record still exists
            var entry = _db.Entry(account);
            var databaseValues = await entry.GetDatabaseValuesAsync(ct);
            
            if (databaseValues == null)
                return null; // Record was deleted by another user
            
            throw new InvalidOperationException(
                "Another user has modified this record. Please refresh and try again.");
        }
    }

    public async Task<bool> DeleteAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account is null) return false;

        // Soft delete
        account.IsDeleted = true;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> SuspendAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account is null) return false;

        account.Status = AccountStatus.Suspended;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> ActivateAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account is null) return false;

        account.Status = AccountStatus.Active;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> CloseAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account is null) return false;

        account.Status = AccountStatus.Closed;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<decimal> GetBalanceAsync(Guid tenantId, Guid accountId, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        return account?.Balance ?? 0;
    }

    public async Task<Account?> UpdateBalanceAsync(Guid tenantId, Guid accountId, decimal newBalance, string? updatedBy = null, CancellationToken ct = default)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == accountId && x.TenantId == tenantId, ct);

        if (account is null) return null;

        account.Balance = newBalance;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;
        account.UpdatedBy = updatedBy;

        await _db.SaveChangesAsync(ct);
        return account;
    }
}
