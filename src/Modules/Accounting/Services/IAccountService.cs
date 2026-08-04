using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public interface IAccountService
{
    // Account CRUD operations
    Task<Account?> GetByIdAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    Task<Account?> GetByNumberAsync(Guid tenantId, string accountNumber, CancellationToken ct = default);
    Task<Account?> GetByCustomerIdAsync(Guid tenantId, Guid customerId, CancellationToken ct = default);
    Task<PagedAccountResponse> ListAsync(Guid tenantId, AccountType? type = null, AccountStatus? status = null, int page = 1, int pageSize = 20, CancellationToken ct = default);
    Task<Account> CreateAsync(Guid tenantId, CreateAccountRequest request, string? createdBy = null, CancellationToken ct = default);
    Task<Account?> UpdateAsync(Guid tenantId, UpdateAccountRequest request, string? updatedBy = null, CancellationToken ct = default);
    Task<bool> DeleteAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    
    // Account status operations
    Task<bool> SuspendAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    Task<bool> ActivateAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    Task<bool> CloseAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    
    // Balance operations
    Task<decimal> GetBalanceAsync(Guid tenantId, Guid accountId, CancellationToken ct = default);
    Task<Account?> UpdateBalanceAsync(Guid tenantId, Guid accountId, decimal newBalance, string? updatedBy = null, CancellationToken ct = default);
}
