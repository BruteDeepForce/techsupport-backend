using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.Infrastructure;
using TechSupport.Technician.Contracts.Events;

namespace Modules.HR.Application;

public interface IEmployeeSyncService
{
    Task SyncTechnicianAsync(TechnicianHrEmployeeSyncRequested message, CancellationToken ct);
}

public sealed class EmployeeSyncService : IEmployeeSyncService
{
    private readonly HRDbContext _db;

    public EmployeeSyncService(HRDbContext db)
    {
        _db = db;
    }

    public async Task SyncTechnicianAsync(TechnicianHrEmployeeSyncRequested message, CancellationToken ct)
    {
        if (message.TenantId == Guid.Empty)
        {
            throw new InvalidOperationException("TenantId is required for HR employee sync.");
        }

        if (message.AppUserId == Guid.Empty)
        {
            throw new InvalidOperationException("AppUserId is required for HR employee sync.");
        }

        var employee = await _db.Employees
            .FirstOrDefaultAsync(x =>
                x.TenantId == message.TenantId &&
                x.UserId == message.AppUserId &&
                x.DeletedAtUtc == null,
                ct);
        var position = await _db.Positions
            .FirstOrDefaultAsync(x => x.TenantId == message.TenantId && 
            (x.Name.Contains("Teknisyen") || x.Name.Contains("Tekniker") || x.Name.Contains("Technician")) && x.IsActive, ct);  
        if (position is null)
        {
            throw new InvalidOperationException("No active position found for Technician in HR.");
        }

        if (employee is null)
        {
            employee = await _db.Employees
                .FirstOrDefaultAsync(x =>
                    x.TenantId == message.TenantId &&
                    x.Email == message.Email &&
                    x.DeletedAtUtc == null,
                    ct);
        }

        var now = DateTime.UtcNow;
        var fullName = string.IsNullOrWhiteSpace(message.FullName)
            ? message.Email
            : message.FullName.Trim();

        if (employee is null)
        {
            // if (!message.BranchId.HasValue || message.BranchId.Value == Guid.Empty)
            // {
            //     throw new InvalidOperationException("BranchId is required to create HR employee projection.");
            // }

            employee = new Employee
            {
                Id = Guid.NewGuid(),
                TenantId = message.TenantId,
                BranchId = message.BranchId ?? Guid.Empty,
                EmployeeNo = GenerateEmployeeNo(),
                FullName = fullName,
                UserId = message.AppUserId,
                Email = message.Email.Trim(),
                Phone = message.PhoneNumber?.Trim(),
                ProfileImageUrl = message.ProfileImageUrl?.Trim(),
                JobsStartDateUtc = message.EmploymentStartDate?.UtcDateTime,
                Status = message.IsActive ? EmployeeStatus.Active : EmployeeStatus.Passive,
                CreatedAtUtc = now,
                UpdatedAtUtc = now,
                PositionId = position.Id
                
            };

            _db.Employees.Add(employee);
        }
        else
        {
            // if (message.BranchId.HasValue && message.BranchId.Value != Guid.Empty)
            // {
            //     employee.BranchId = message.BranchId.Value;
            // }

            employee.FullName = fullName;
            employee.UserId = message.AppUserId;
            employee.Email = message.Email.Trim();
            employee.Phone = message.PhoneNumber?.Trim();
            employee.ProfileImageUrl = message.ProfileImageUrl?.Trim();
            employee.JobsStartDateUtc = message.EmploymentStartDate?.UtcDateTime;
            employee.Status = message.IsActive ? EmployeeStatus.Active : EmployeeStatus.Passive;
            employee.UpdatedAtUtc = now;
        }

        await _db.SaveChangesAsync(ct);
    }

    private static string GenerateEmployeeNo()
        => $"EMP-{DateTime.UtcNow:yyyyMMddHHmmssfff}";
}
