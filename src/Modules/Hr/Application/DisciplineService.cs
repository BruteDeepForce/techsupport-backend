using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;

namespace Modules.HR.Application;

public interface IDisciplineService
{
    Task<HRServiceResult<DisciplineResponse>> CreateAsync(Guid tenantId, CreateDisciplineRequest request, CancellationToken ct);
    Task<HRServiceResult<DisciplineResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<DisciplineResponse>>> ListAsync(Guid tenantId, CancellationToken ct);
    Task<HRServiceResult<DisciplineResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateDisciplineRequest request, CancellationToken ct);

    Task<HRServiceResult<DisciplineEmployeeRecordResponse>> CreateRecordAsync(Guid tenantId, CreateDisciplineEmployeeRecordRequest request, CancellationToken ct);
    Task<HRServiceResult<DisciplineEmployeeRecordResponse>> GetRecordByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<DisciplineEmployeeRecordResponse>>> ListRecordsAsync(
        Guid tenantId,
        Guid? employeeId,
        Guid? disciplineId,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct);

    Task<HRServiceResult<DisciplineEmployeeRecordResponse>> UpdateRecordAsync(Guid tenantId, Guid id, UpdateDisciplineEmployeeRecordRequest request, CancellationToken ct);
}

public sealed class DisciplineService : IDisciplineService
{
    private readonly HRDbContext _db;

    public DisciplineService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<DisciplineResponse>> CreateAsync(Guid tenantId, CreateDisciplineRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<DisciplineResponse>.Fail("TenantId is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            return HRServiceResult<DisciplineResponse>.Fail("Description is required.");
        }

        if (request.PenaltyAmount < 0)
        {
            return HRServiceResult<DisciplineResponse>.Fail("PenaltyAmount cannot be negative.");
        }

        var now = DateTime.UtcNow;
        var discipline = new Discipline
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = Guid.Empty,
            Description = request.Description.Trim(),
            PenaltyAmount = decimal.Round(request.PenaltyAmount, 2),
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _db.Disciplines.Add(discipline);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DisciplineResponse>.Ok(ToResponse(discipline));
    }

    public async Task<HRServiceResult<DisciplineResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var discipline = await _db.Disciplines
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return discipline is null
            ? HRServiceResult<DisciplineResponse>.NotFound("Discipline not found.")
            : HRServiceResult<DisciplineResponse>.Ok(ToResponse(discipline));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<DisciplineResponse>>> ListAsync(Guid tenantId, CancellationToken ct)
    {
        var disciplines = await _db.Disciplines
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<DisciplineResponse>>.Ok(disciplines.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<DisciplineResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateDisciplineRequest request, CancellationToken ct)
    {
        var discipline = await _db.Disciplines
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (discipline is null)
        {
            return HRServiceResult<DisciplineResponse>.NotFound("Discipline not found.");
        }

        if (request.Description is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Description))
            {
                return HRServiceResult<DisciplineResponse>.Fail("Description cannot be empty.");
            }

            discipline.Description = request.Description.Trim();
        }

        if (request.PenaltyAmount.HasValue)
        {
            if (request.PenaltyAmount.Value < 0)
            {
                return HRServiceResult<DisciplineResponse>.Fail("PenaltyAmount cannot be negative.");
            }

            discipline.PenaltyAmount = decimal.Round(request.PenaltyAmount.Value, 2);
        }

        discipline.UpdatedAtUtc = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DisciplineResponse>.Ok(ToResponse(discipline));
    }

    public async Task<HRServiceResult<DisciplineEmployeeRecordResponse>> CreateRecordAsync(Guid tenantId, CreateDisciplineEmployeeRecordRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.Fail("TenantId is required.");
        }

        if (request.EmployeeId == Guid.Empty || request.DisciplineId == Guid.Empty)
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.Fail("EmployeeId and DisciplineId are required.");
        }

        if (string.IsNullOrWhiteSpace(request.Description))
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.Fail("Description is required.");
        }

        var employeeExists = await _db.Employees
            .AsNoTracking()
            .AnyAsync(x =>
                x.Id == request.EmployeeId &&
                x.TenantId == tenantId &&
                x.DeletedAtUtc == null,
                ct);

        if (!employeeExists)
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.NotFound("Employee not found.");
        }

        var disciplineExists = await _db.Disciplines
            .AsNoTracking()
            .AnyAsync(x =>
                x.Id == request.DisciplineId &&
                x.TenantId == tenantId,
                ct);

        if (!disciplineExists)
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.NotFound("Discipline not found.");
        }

        var record = new DisciplineEmployeeRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = Guid.Empty,
            EmployeeId = request.EmployeeId,
            DisciplineId = request.DisciplineId,
            Description = request.Description.Trim(),
            IncidentDate = request.IncidentDate,
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.DisciplineEmployeeRecords.Add(record);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DisciplineEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    public async Task<HRServiceResult<DisciplineEmployeeRecordResponse>> GetRecordByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var record = await _db.DisciplineEmployeeRecords
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return record is null
            ? HRServiceResult<DisciplineEmployeeRecordResponse>.NotFound("Discipline employee record not found.")
            : HRServiceResult<DisciplineEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<DisciplineEmployeeRecordResponse>>> ListRecordsAsync(
        Guid tenantId,
        Guid? employeeId,
        Guid? disciplineId,
        DateTime? startDate,
        DateTime? endDate,
        CancellationToken ct)
    {
        if (startDate.HasValue && endDate.HasValue && startDate.Value.Date > endDate.Value.Date)
        {
            return HRServiceResult<IReadOnlyCollection<DisciplineEmployeeRecordResponse>>.Fail("startDate must be earlier than or equal to endDate.");
        }

        var query = _db.DisciplineEmployeeRecords
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (employeeId.HasValue && employeeId.Value != Guid.Empty)
        {
            query = query.Where(x => x.EmployeeId == employeeId.Value);
        }

        if (disciplineId.HasValue && disciplineId.Value != Guid.Empty)
        {
            query = query.Where(x => x.DisciplineId == disciplineId.Value);
        }

        if (startDate.HasValue)
        {
            var fromDate = startDate.Value.Date;
            query = query.Where(x => x.IncidentDate.Date >= fromDate);
        }

        if (endDate.HasValue)
        {
            var toDate = endDate.Value.Date;
            query = query.Where(x => x.IncidentDate.Date <= toDate);
        }

        var records = await query
            .OrderByDescending(x => x.IncidentDate)
            .ThenByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<DisciplineEmployeeRecordResponse>>.Ok(records.Select(ToRecordResponse).ToList());
    }

    public async Task<HRServiceResult<DisciplineEmployeeRecordResponse>> UpdateRecordAsync(Guid tenantId, Guid id, UpdateDisciplineEmployeeRecordRequest request, CancellationToken ct)
    {
        var record = await _db.DisciplineEmployeeRecords
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (record is null)
        {
            return HRServiceResult<DisciplineEmployeeRecordResponse>.NotFound("Discipline employee record not found.");
        }

        if (request.DisciplineId.HasValue)
        {
            if (request.DisciplineId.Value == Guid.Empty)
            {
                return HRServiceResult<DisciplineEmployeeRecordResponse>.Fail("DisciplineId cannot be empty.");
            }

            var disciplineExists = await _db.Disciplines
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Id == request.DisciplineId.Value &&
                    x.TenantId == tenantId &&
                    x.BranchId == record.BranchId,
                    ct);

            if (!disciplineExists)
            {
                return HRServiceResult<DisciplineEmployeeRecordResponse>.NotFound("Discipline not found.");
            }

            record.DisciplineId = request.DisciplineId.Value;
        }

        if (request.Description is not null)
        {
            if (string.IsNullOrWhiteSpace(request.Description))
            {
                return HRServiceResult<DisciplineEmployeeRecordResponse>.Fail("Description cannot be empty.");
            }

            record.Description = request.Description.Trim();
        }

        if (request.IncidentDate.HasValue)
        {
            record.IncidentDate = request.IncidentDate.Value;
        }

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<DisciplineEmployeeRecordResponse>.Ok(ToRecordResponse(record));
    }

    private static DisciplineResponse ToResponse(Discipline discipline)
        => new(
            discipline.Id,
            discipline.TenantId,
            discipline.BranchId,
            discipline.Description,
            discipline.PenaltyAmount,
            discipline.CreatedAtUtc,
            discipline.UpdatedAtUtc);

    private static DisciplineEmployeeRecordResponse ToRecordResponse(DisciplineEmployeeRecord record)
        => new(
            record.Id,
            record.TenantId,
            record.BranchId,
            record.EmployeeId,
            record.DisciplineId,
            record.Description,
            record.IncidentDate,
            record.CreatedAtUtc);
}
