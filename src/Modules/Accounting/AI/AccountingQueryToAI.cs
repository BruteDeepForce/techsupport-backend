using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Contracts.AI;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.AI;

/// <summary>
/// AI modülünün muhasebe verisini okumasını sağlayan implementasyon.
/// </summary>
public sealed class AccountingQueryToAI : IAccountingQueryToAI
{
    private readonly AccountingDbContext _db;

    public AccountingQueryToAI(AccountingDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyCollection<AccountInfoResponse>> QueryAccountsAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default)
    {
        var query = _db.Accounts
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        return await query
            .OrderBy(x => x.Type)
            .ThenBy(x => x.Name)
            .Select(x => new AccountInfoResponse(
                x.Id,
                x.AccountNumber,
                x.Name,
                x.Description,
                x.Type.ToString(),
                x.Status.ToString(),
                x.Balance,
                x.TotalBorc,
                x.TotalAlacak,
                x.CreditLimit))
            .ToListAsync(ct);
    }

    public async Task<AccountingSummaryResponse> GetAccountingSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default)
    {
        var now = DateTimeOffset.UtcNow;

        var accounts = _db.Accounts
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && (!branchId.HasValue || x.BranchId == branchId));

        var invoiceQuery = _db.Invoices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId
                        && (!branchId.HasValue || x.BranchId == branchId)
                        && x.Status != InvoiceStatus.Cancelled
                        && x.Status != InvoiceStatus.Draft);

        var paymentQuery = _db.Payments
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId
                        && (!branchId.HasValue || x.BranchId == branchId)
                        && x.Status == PaymentStatus.Tamamlandi);

        var totalReceivable = await accounts
            .Where(x => x.Type == AccountType.CariHesap)
            .SumAsync(x => (decimal?)x.Balance, ct) ?? 0m;

        var totalPayable = await accounts
            .Where(x => x.Type == AccountType.Gider || x.Type == AccountType.Kasa || x.Type == AccountType.Banka)
            .SumAsync(x => (decimal?)x.Balance, ct) ?? 0m;

        var totalInvoiced = await invoiceQuery.SumAsync(x => (decimal?)x.TotalAmount, ct) ?? 0m;
        var totalPaid = await paymentQuery.SumAsync(x => (decimal?)x.Amount, ct) ?? 0m;

        var invoiceCount = await invoiceQuery.CountAsync(ct);

        // Overdue: explicitly marked Overdue, or due date passed while not fully paid
        var overdueInvoiceCount = await invoiceQuery
            .CountAsync(
                x => x.Status == InvoiceStatus.Overdue
                     || (x.DueDate < now && x.PaidAmount < x.TotalAmount),
                ct);

        return new AccountingSummaryResponse(
            totalReceivable,
            totalPayable,
            totalInvoiced,
            totalPaid,
            totalInvoiced - totalPaid,
            invoiceCount,
            overdueInvoiceCount);
    }

    public async Task<IReadOnlyCollection<InvoiceInfoResponse>> QueryInvoicesAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        Guid? customerId,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Invoices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (customerId.HasValue)
        {
            query = query.Where(x => x.CustomerId == customerId.Value);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (Enum.TryParse<InvoiceStatus>(status.Trim(), ignoreCase: true, out var parsed))
            {
                query = query.Where(x => x.Status == parsed);
            }
        }

        return await query
            .OrderByDescending(x => x.IssueDate)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new InvoiceInfoResponse(
                x.Id,
                x.InvoiceNumber,
                x.CustomerId,
                x.Status.ToString(),
                x.Type.ToString(),
                x.TotalAmount,
                x.PaidAmount,
                x.TotalAmount - x.PaidAmount,
                x.IssueDate,
                x.DueDate))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<PaymentInfoResponse>> QueryPaymentsAsync(
        Guid tenantId,
        Guid? branchId,
        string? status,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Payments
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (Enum.TryParse<PaymentStatus>(status.Trim(), ignoreCase: true, out var parsed))
            {
                query = query.Where(x => x.Status == parsed);
            }
        }

        return await query
            .OrderByDescending(x => x.PaymentDate)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new PaymentInfoResponse(
                x.Id,
                x.PaymentNumber,
                x.CustomerId,
                x.InvoiceId,
                x.Method.ToString(),
                x.Status.ToString(),
                x.Amount,
                x.PaymentDate))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<CariHesapHareketInfoResponse>> QueryCariHesapHareketleriAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? customerId,
        DateTimeOffset? from,
        DateTimeOffset? to,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.CariHesapHareketleri
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (customerId.HasValue)
        {
            query = query.Where(x => x.CustomerId == customerId.Value);
        }

        if (from.HasValue)
        {
            var fromUtc = from.Value.UtcDateTime;
            query = query.Where(x => x.IslemTarihi >= fromUtc);
        }

        if (to.HasValue)
        {
            var toUtc = to.Value.UtcDateTime;
            query = query.Where(x => x.IslemTarihi <= toUtc);
        }

        return await query
            .OrderByDescending(x => x.IslemTarihi)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new CariHesapHareketInfoResponse(
                x.Id,
                x.CustomerId,
                x.InvoiceId,
                x.PaymentId,
                x.HareketTipi.ToString(),
                x.Borc,
                x.Alacak,
                x.Bakiye,
                x.Aciklama,
                x.IslemTarihi))
            .ToListAsync(ct);
    }

    private static (int Page, int PageSize) NormalizePaging(int page, int pageSize)
    {
        var safePage = page < 1 ? 1 : page;
        var safePageSize = pageSize switch
        {
            < 1 => 20,
            > 200 => 200,
            _ => pageSize
        };

        return (safePage, safePageSize);
    }
}