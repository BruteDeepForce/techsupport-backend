using System;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.DTO;

// ==================== Account DTOs ====================

public class CreateAccountRequest
{
    public string Name { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public AccountType Type { get; set; } = AccountType.CariHesap;
    public Guid? CustomerId { get; set; }
    public Guid? BranchId { get; set; }
    public decimal CreditLimit { get; set; }
    public string? Description { get; set; }
}

public class UpdateAccountRequest
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public string? AccountNumber { get; set; }
    public AccountType? Type { get; set; }
    public Guid? CustomerId { get; set; }
    public decimal? CreditLimit { get; set; }
    public string? Description { get; set; }
    public AccountStatus? Status { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}

public class AccountResponse
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    public Guid? CustomerId { get; set; }
    public string AccountNumber { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public AccountType Type { get; set; }
    public AccountStatus Status { get; set; }
    public decimal Balance { get; set; }
    public decimal TotalBorc { get; set; }
    public decimal TotalAlacak { get; set; }
    public decimal CreditLimit { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
    public string? CreatedBy { get; set; }
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    public string? UpdatedBy { get; set; }
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();
}

public class AccountListItemResponse
{
    public Guid Id { get; set; }
    public string AccountNumber { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public AccountType Type { get; set; }
    public AccountStatus Status { get; set; }
    public decimal Balance { get; set; }
    public decimal TotalBorc { get; set; }
    public decimal TotalAlacak { get; set; }
    public decimal CreditLimit { get; set; }
    public Guid? CustomerId { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; }
}

public class PagedAccountResponse
{
    public IReadOnlyList<AccountListItemResponse> Items { get; set; } = Array.Empty<AccountListItemResponse>();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
}
