using Microsoft.EntityFrameworkCore;
using TechSupport.Customer.Contracts.AI;
using TechSupport.Customer.Data;
using TechSupport.Customer.Domain.Entities;

namespace TechSupport.Customer.AI;

/// <summary>
/// AI modülünün müşteri verisini okumasını sağlayan implementasyon.
/// </summary>
public sealed class CustomerQueryToAI : ICustomerQueryToAI
{
    private readonly CustomerDbContext _db;

    public CustomerQueryToAI(CustomerDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyCollection<CustomerInfoResponse>> QueryCustomersAsync(
        Guid tenantId,
        Guid? branchId,
        string? search,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.Customers
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x =>
                EF.Functions.ILike(x.Name, $"%{term}%") ||
                EF.Functions.ILike(x.Email, $"%{term}%") ||
                EF.Functions.ILike(x.PhoneNumber, $"%{term}%"));
        }

        return await query
            .OrderBy(x => x.Name)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new CustomerInfoResponse(
                x.Id,
                x.Name,
                x.Email,
                x.PhoneNumber,
                x.Devices.Count(d => d.DeletedAtUtc == null)))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyCollection<CustomerDeviceInfoResponse>> QueryCustomerDevicesAsync(
        Guid tenantId,
        Guid? branchId,
        Guid? customerId,
        int page,
        int pageSize,
        CancellationToken ct = default)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);

        var query = _db.CustomerDevices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.DeletedAtUtc == null);

        if (branchId.HasValue)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (customerId.HasValue)
        {
            query = query.Where(x => x.CustomerId == customerId.Value);
        }

        return await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new CustomerDeviceInfoResponse(
                x.DeviceId,
                x.CustomerId,
                x.Customer != null ? x.Customer.Name : null,
                x.Brand,
                x.Model,
                x.SerialNumber,
                x.BarcodeNumber,
                x.ProblemDescription,
                x.Status,
                x.IsActive,
                x.GuaranteePeriod,
                x.WarrantyEndAtUtc))
            .ToListAsync(ct);
    }

    public async Task<CustomerSummaryResponse> GetCustomerSummaryAsync(
        Guid tenantId,
        Guid? branchId,
        CancellationToken ct = default)
    {
        var now = DateTimeOffset.UtcNow;

        var customerQuery = _db.Customers
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && (!branchId.HasValue || x.BranchId == branchId));

        var totalCustomerCount = await customerQuery.CountAsync(ct);

        var deviceQuery = _db.CustomerDevices
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId
                        && x.DeletedAtUtc == null
                        && (!branchId.HasValue || x.BranchId == branchId));

        var totalDeviceCount = await deviceQuery.CountAsync(ct);
        var activeDeviceCount = await deviceQuery.CountAsync(x => x.IsActive, ct);

        var expiredWarrantyCount = await deviceQuery.CountAsync(
            x => x.WarrantyEndAtUtc != null && x.WarrantyEndAtUtc < now,
            ct);

        var problemDeviceCount = await deviceQuery.CountAsync(
            x => x.ProblemDescription != null && x.ProblemDescription != string.Empty,
            ct);

        return new CustomerSummaryResponse(
            totalCustomerCount,
            totalDeviceCount,
            activeDeviceCount,
            expiredWarrantyCount,
            problemDeviceCount);
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