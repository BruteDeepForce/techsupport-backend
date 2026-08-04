using MassTransit;
using MassTransit.Futures.Contracts;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Technician.Contracts.Events;
using TechSupport.Technician.Data;
using TechSupport.Technician.Domain.Entities;
using TechSupport.Technician.DTO;
using static TechSupport.Technician.Services.TechnicianService;

namespace TechSupport.Technician.Services;

public interface ITechnicianService
{
    Task<TechnicianProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId, string firstName, string email,
    string? phoneNumber, string temporaryPassword, List<string>? experts, DateTimeOffset? employmentStartDate, CancellationToken ct);
    Task<TechnicianProvisionRequest?> GetProvisioningStatusAsync(Guid correlationId, CancellationToken ct);
    Task CompleteProvisioningAsync(Guid correlationId, Guid appUserId, Guid tenantId, Guid? branchId, string firstName, string email, string? phoneNumber, CancellationToken ct);
    Task FailProvisioningAsync(Guid correlationId, string reason, CancellationToken ct);
    Task<Technician.Domain.Entities.Technician?> GetByIdAsync(Guid tenantId, Guid technicianId, CancellationToken ct);
    Task<IReadOnlyList<TechnicianResponseDTO>> ListAsync(Guid tenantId, CancellationToken ct);
    Task<bool> SetActiveAsync(Guid tenantId, Guid technicianId, bool isActive, CancellationToken ct);
    Task OperationAssignAsync(Guid tenantId, Guid operationId, Guid? branchId, Guid technicianId, Guid customerId, Guid deviceId, string title, string description, string operationType, DateTimeOffset occurredAtUtc, CancellationToken ct);
    Task<Technician.Domain.Entities.TechnicianOperation> UpdateOperationStatusAsync(Guid tenantId, Guid operationId, Guid technicianUserId, string technicianInfo, string status, CancellationToken ct);
    Task<bool> CreateTechnicianExpertiseAsync(Guid tenantId, string expertise, CancellationToken ct);
    Task<List<TechnicianExpertResponseDTO>> GetTechnicianExpertiseByNameAsync(Guid tenantId, CancellationToken ct);
    Task<object> UpdateTechnicianProfileAsync(Guid tenantId, Guid? branchid, Guid technicianId, string? name, string? email,
    string? phoneNumber, List<string>? expertiseIds, IFormFile? picture, CancellationToken ct);

}

public sealed class TechnicianService : ITechnicianService
{
    private readonly TechnicianDbContext _db;
    private readonly IBus _bus;
    private readonly S3Service _s3Service;

    private readonly ILogger<TechnicianService> _logger;

    public TechnicianService(TechnicianDbContext db, IBus bus, S3Service s3Service, ILogger<TechnicianService> logger)
    {
        _db = db;
        _bus = bus;
        _s3Service = s3Service;
        _logger = logger;
    }
    public record TechnicianExpertResponseDTO(Guid Id, string ExpertiseName);

    public async Task OperationAssignAsync(Guid tenantId, Guid operationId, Guid? branchId, Guid technicianId, Guid customerId, Guid deviceId, string title, string description, string operationType, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        var technician = await _db.Technicians.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.AppUserId == technicianId, ct);
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

        await _db.TechnicianOperations.AddAsync(item, ct);
        technician.IsActive = true; //* Ensure technician is active
        await _db.SaveChangesAsync(ct);
    }

    public async Task<bool> CreateTechnicianExpertiseAsync(Guid tenantId, string expertise, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(expertise))
            return false;
        var normalizedExpertise = expertise.Trim().ToLower();
        var exists = await _db.TechnicianExperts.AnyAsync(x => x.TenantId == tenantId
        && x.ExpertiseName.ToLower() == normalizedExpertise, ct);

        if (exists)
            return false;

        var item = new TechnicianExpert
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            ExpertiseName = expertise.Trim(),
        };

        await _db.TechnicianExperts.AddAsync(item, ct);
        await _db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<List<TechnicianExpertResponseDTO>> GetTechnicianExpertiseByNameAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.TechnicianExperts
            .Where(x => x.TenantId == tenantId)
            .Select(x => new TechnicianExpertResponseDTO(x.Id, x.ExpertiseName))
            .ToListAsync(ct);
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

    public async Task<TechnicianProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId,
    string firstName, string email, string? phoneNumber, string temporaryPassword, List<string>? experts,
    DateTimeOffset? employmentStartDate, CancellationToken ct)
    {
        var correlationId = Guid.NewGuid();
        var requestId = Guid.NewGuid();
        var expertList = experts?.
        Select(e => new ExpertsTechnicianProvision
        {
            Id = Guid.NewGuid(),
            ExpertiseId = Guid.TryParse(e, out var expId) ? expId : (Guid?)null
        }).ToList() ?? new List<ExpertsTechnicianProvision>();

        var request = new TechnicianProvisionRequest
        {
            Id = requestId,
            CorrelationId = correlationId,
            TenantId = tenantId,
            BranchId = branchId,
            Name = firstName.Trim(),
            Email = email.Trim(),
            PhoneNumber = phoneNumber?.Trim() ?? string.Empty,
            Status = ProvisioningStatus.Pending,
            CreatedAtUtc = DateTimeOffset.UtcNow,
            EmploymentStartDate = employmentStartDate,
            ExpertsId = expertList
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
        var expertid = await _db.TechnicianProvisionRequests.Where(x => x.CorrelationId == correlationId)
        .SelectMany(x => x.ExpertsId)
        .Select(e => new TechnicianExpertMapping
        {
            tenantId = tenantId,
            BranchId = branchId,
            TechnicianExpertId = e.ExpertiseId ?? Guid.Empty
        })
        .ToListAsync(ct);

        _logger.LogInformation("Fetched {Count} expertise mappings for CorrelationId {CorrelationId}", expertid.Count, correlationId);

        if (expertid.Count == 0)
        {
            _logger.LogInformation("No expertise mappings found for CorrelationId {CorrelationId}", correlationId);
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
                IsActive = true,
                EmploymentStartDate = request.EmploymentStartDate,
                TechnicianExpertMappings = expertid
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

        await _bus.Publish(new TechnicianHrEmployeeSyncRequested(
            correlationId,
            existing.Id,
            appUserId,
            tenantId,
            branchId,
            existing.FirstName,
            existing.Email,
            existing.PhoneNumber,
            existing.PictureUrl,
            existing.IsActive,
            existing.EmploymentStartDate,
            DateTimeOffset.UtcNow), ct);
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
        return _db.Technicians.AsNoTracking().FirstOrDefaultAsync(x => x.TenantId == tenantId && x.AppUserId == technicianId, ct);
    }

    public async Task<IReadOnlyList<TechnicianResponseDTO>> ListAsync(Guid tenantId, CancellationToken ct)
    {
        return await _db.Technicians.AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .Select(t => new TechnicianResponseDTO
            {
                TenantId = t.TenantId,
                UserId = t.AppUserId ?? Guid.Empty,
                Name = t.FirstName,
                Email = t.Email,
                PhoneNumber = t.PhoneNumber,
                PictureUrl = t.PictureUrl,
                IsActive = t.IsActive,
                Specializations = t.TechnicianExpertMappings.Select(m => m.TechnicianExpert.ExpertiseName).ToList()
            })
            .ToListAsync(ct);
    }

    public async Task<bool> SetActiveAsync(Guid tenantId, Guid technicianId, bool isActive, CancellationToken ct)
    {
        var technician = await _db.Technicians.FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == technicianId, ct);
        if (technician is null) return false;

        technician.IsActive = isActive;
        await _db.SaveChangesAsync(ct);

        if (technician.AppUserId.HasValue)
        {
            await _bus.Publish(new TechnicianHrEmployeeSyncRequested(
                Guid.NewGuid(),
                technician.Id,
                technician.AppUserId.Value,
                technician.TenantId,
                technician.BranchId,
                technician.FirstName,
                technician.Email,
                technician.PhoneNumber,
                technician.PictureUrl,
                technician.IsActive,
                technician.EmploymentStartDate,
                DateTimeOffset.UtcNow), ct);
        }

        return true;
    }

    public async Task<object> UpdateTechnicianProfileAsync(Guid tenantId, Guid? branchId, Guid technicianId, string? name,
    string? email, string? phoneNumber, List<string>? expertIds, IFormFile? picture, CancellationToken ct)
    {
        var technician = await _db.Technicians.Include(x => x.TechnicianExpertMappings).FirstOrDefaultAsync(x => x.TenantId == tenantId && x.AppUserId == technicianId, ct);
        if (technician is null) return new { Success = false, Message = "Technician not found" };

        technician.FirstName = name ?? technician.FirstName;
        technician.Email = email ?? technician.Email;
        technician.PhoneNumber = phoneNumber ?? technician.PhoneNumber;


        technician.TechnicianExpertMappings = expertIds != null
            ? expertIds.Select(e => new TechnicianExpertMapping
            {
                TechnicianId = technicianId,
                tenantId = tenantId,
                BranchId = branchId,
                TechnicianExpertId = GetParsedGuid(e)
            }).ToList()
            : technician.TechnicianExpertMappings;


        technician.PictureUrl = picture != null ? await ProfilePictureUploadAsync(tenantId, technicianId, picture, ct)
        : technician.PictureUrl;

        _db.Technicians.Update(technician);
        await _db.SaveChangesAsync(ct);

        if (technician.AppUserId.HasValue)
        {
            await _bus.Publish(new TechnicianHrEmployeeSyncRequested(
                Guid.NewGuid(),
                technician.Id,
                technician.AppUserId.Value,
                technician.TenantId,
                technician.BranchId,
                technician.FirstName,
                technician.Email,
                technician.PhoneNumber,
                technician.PictureUrl,
                technician.IsActive,
                technician.EmploymentStartDate,
                DateTimeOffset.UtcNow), ct);
        }

        return new { Success = true, Message = $"Picture Url: {technician.PictureUrl}" };
    }

    private async Task<string> ProfilePictureUploadAsync(Guid tenantId, Guid technicianId, IFormFile picture, CancellationToken ct)
    {
        if (picture == null || picture.Length == 0)
            return string.Empty;

        string key = $"technicians/{tenantId}/{technicianId}/profile-picture/{Guid.NewGuid()}";
        var filePath = await _s3Service.UploadFileAsync(picture, key, ct);
        if (string.IsNullOrEmpty(filePath))
        {
            _logger.LogError("Failed to upload profile picture for TechnicianId {TechnicianId} in TenantId {TenantId}", technicianId, tenantId);
            return string.Empty;
        }

        return filePath;
    }

    private Guid GetParsedGuid(string? input)
    {
        if (!Guid.TryParse(input, out var result))
        {
            throw new ArgumentException($"Invalid GUID format: {input}");
        }
        return result;
    }
}
