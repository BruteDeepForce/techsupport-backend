using MassTransit;
using MassTransit.Futures.Contracts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Technician.Contracts.Events;
using TechSupport.Technician.Data;
using TechSupport.Technician.Domain.Entities;

namespace TechSupport.Technician.Services;

public interface ITechnicianService
{
    Task<TechnicianProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId, string firstName,  string email, string? phoneNumber, string temporaryPassword, CancellationToken ct);
    Task<TechnicianProvisionRequest?> GetProvisioningStatusAsync(Guid correlationId, CancellationToken ct);
    Task CompleteProvisioningAsync(Guid correlationId, Guid appUserId, Guid tenantId, Guid? branchId, string firstName, string email, string? phoneNumber, CancellationToken ct);
    Task FailProvisioningAsync(Guid correlationId, string reason, CancellationToken ct);
    Task<Technician.Domain.Entities.Technician?> GetByIdAsync(Guid tenantId, Guid technicianId, CancellationToken ct);
    Task<IReadOnlyList<Technician.Domain.Entities.Technician>> ListAsync(Guid tenantId, CancellationToken ct);
    Task<bool> SetActiveAsync(Guid tenantId, Guid technicianId, bool isActive, CancellationToken ct);
    Task OperationAssignAsync(Guid tenantId, Guid operationId, Guid? branchId, Guid technicianId, Guid customerId, Guid deviceId, string title, string description, string operationType, DateTimeOffset occurredAtUtc, CancellationToken ct);

    Task<Technician.Domain.Entities.TechnicianOperation> UpdateOperationStatusAsync(Guid tenantId, Guid operationId, Guid technicianUserId, string technicianInfo, string status, CancellationToken ct);
}

public sealed class TechnicianService : ITechnicianService
{
    private readonly TechnicianDbContext _db;
    private readonly IBus _bus;

    private readonly ILogger<TechnicianService> _logger;

    public TechnicianService(TechnicianDbContext db, IBus bus, ILogger<TechnicianService> logger)
    {
        _db = db;
        _bus = bus;
        _logger = logger;
    }

    //!burası yanlış
    public async Task OperationAssignAsync(Guid tenantId, Guid operationId, Guid? branchId, Guid technicianId, Guid customerId, Guid deviceId, string title, string description, string operationType, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var technician = await _db.Technicians.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == technicianId, ct);
        if (technician is null)        
        {
            _logger.LogError("Technician with ID {TechnicianId} not found for tenant {TenantId}", technicianId, tenantId);
            throw new InvalidOperationException("Technician not found");
        }
        var item = new Technician.Domain.Entities.TechnicianOperation
        {
            Id = Guid.NewGuid(),
            OperationId = operationId,
            TenantId = tenantId,
            BranchId = branchId,
            CustomerId = customerId,
            AssignedAtUtc = DateTimeOffset.UtcNow,
            AssignedTechnicianId = technician.Id, 
            DeviceId = deviceId,
            Title = title,
            Description = description,
            OperationType = operationType,
            CreatedAtUtc = occurredAtUtc,
            Status = TechnicianOperationStatus.Assigned
        };

        _db.TechnicianOperations.Add(item);
        technician.IsActive = true; //* Ensure technician is active
        await _db.SaveChangesAsync(ct);
    }

    public async Task<Technician.Domain.Entities.TechnicianOperation> UpdateOperationStatusAsync(
        Guid tenantId,
        Guid operationId,
        Guid technicianUserId,
        string technicianInfo,
        string status,
        CancellationToken ct)
    {
        var op = await _db.TechnicianOperations
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.OperationId == operationId, ct);

        if (op is null)
            throw new InvalidOperationException("Technician operation not found");

        if (!Enum.TryParse<TechnicianOperationStatus>(status, true, out var newStatus))
            throw new InvalidOperationException("Invalid status value");

        var oldStatus = op.Status;
        if (oldStatus == newStatus)
            return op;

        op.Status = newStatus;
        await _db.SaveChangesAsync(ct);

        await _bus.Publish(new TechnicianOperationStatusChanged(
            op.OperationId,
            op.TenantId,
            op.BranchId,
            technicianUserId,
            technicianInfo,
            newStatus.ToString(),
            DateTimeOffset.UtcNow), ct);

        return op;
    }

    public async Task<TechnicianProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId, string firstName, string email, string? phoneNumber, string temporaryPassword, CancellationToken ct)
    {
        var correlationId = Guid.NewGuid();

        var request = new TechnicianProvisionRequest
        {
            Id = Guid.NewGuid(),
            CorrelationId = correlationId,
            TenantId = tenantId,
            BranchId = branchId,
            Name = firstName.Trim(),
            Email = email.Trim(),
            PhoneNumber = phoneNumber?.Trim() ?? string.Empty,
            Status = ProvisioningStatus.Pending,
            CreatedAtUtc = DateTimeOffset.UtcNow
        };

        await _db.TechnicianProvisionRequests.AddAsync(request, ct);
        await _db.SaveChangesAsync(ct);

        await _bus.Publish(new TechnicianAccountProvisionRequested(
            request.CorrelationId,
            request.TenantId,
            request.BranchId,
            request.Name,
            request.Email,
            request.PhoneNumber,
            temporaryPassword), ct);

        //! direkt requesti neden dönüyorsun saçma pending dönüyor çünkü. consume edip tekrar bakmamız lazım.
        
        return request;
    }

    public Task<TechnicianProvisionRequest?> GetProvisioningStatusAsync(Guid correlationId, CancellationToken ct)
    {
        return _db.TechnicianProvisionRequests.AsNoTracking().FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
    }

    public async Task CompleteProvisioningAsync(Guid correlationId, Guid appUserId, Guid tenantId, Guid? branchId, string firstName, string email, string? phoneNumber, CancellationToken ct)
    {
        var request = await _db.TechnicianProvisionRequests.FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
        if (request is null || request.Status == ProvisioningStatus.Completed)
        {
            return;
        }
        _logger.LogInformation("{CorrelationId}: Starting provisioning completion for AppUserId {AppUserId}, TenantId {TenantId}, Email {Email}", correlationId, appUserId, tenantId, email);

        var existing = await _db.Technicians.FirstOrDefaultAsync(x => x.AppUserId == appUserId || (x.TenantId == tenantId && x.Email == email), ct);
        if (existing is null)
        {
            _logger.LogInformation("Creating new technician record for AppUserId {AppUserId}, TenantId {TenantId}, Email {Email}", appUserId, tenantId, email);
            existing = new Technician.Domain.Entities.Technician
            {
                Id = Guid.NewGuid(),
                AppUserId = appUserId,
                TenantId = tenantId,
                BranchId = branchId,
                FirstName = firstName,
                Email = email,
                PhoneNumber = phoneNumber ?? string.Empty,
                IsActive = true
            };

            await _db.Technicians.AddAsync(existing, ct);
        }
        else
        {
            existing.AppUserId = appUserId;
            existing.FirstName = firstName;
            existing.Email = email;
            existing.PhoneNumber = phoneNumber ?? string.Empty;
            existing.BranchId = branchId;
            existing.IsActive = true;
        }
        _logger.LogInformation("Completed");
        request.Status = ProvisioningStatus.Completed;
        request.AppUserId = appUserId;
        request.TechnicianId = existing.Id;
        request.CompletedAtUtc = DateTimeOffset.UtcNow;
        request.FailureReason = null;

        await _db.SaveChangesAsync(ct);
    }

    public async Task FailProvisioningAsync(Guid correlationId, string reason, CancellationToken ct)
    {
        var request = await _db.TechnicianProvisionRequests.FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
        if (request is null || request.Status == ProvisioningStatus.Completed)
        {
            return;
        }

        request.Status = ProvisioningStatus.Failed;
        request.FailureReason = reason;
        request.CompletedAtUtc = DateTimeOffset.UtcNow;

        await _db.SaveChangesAsync(ct);
    }

    public Task<Technician.Domain.Entities.Technician?> GetByIdAsync(Guid tenantId, Guid technicianId, CancellationToken ct)
    {
        return _db.Technicians.AsNoTracking().FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == technicianId, ct);
    }

    public async Task<IReadOnlyList<Technician.Domain.Entities.Technician>> ListAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.Technicians
        .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderBy(x => x.FirstName)
            .ToListAsync(ct);
    }

    public async Task<bool> SetActiveAsync(Guid tenantId, Guid technicianId, bool isActive, CancellationToken ct)
    {
        var technician = await _db.Technicians.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == technicianId, ct);
        if (technician is null) return false;

        technician.IsActive = isActive;
        await _db.SaveChangesAsync(ct);
        return true;
    }
}
