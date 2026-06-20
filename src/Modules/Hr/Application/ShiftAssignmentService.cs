using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query.SqlExpressions;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;
using Npgsql;
using TechSupport.Hr.SignalR;

namespace Modules.HR.Application;

public interface IShiftAssignmentService
{
    Task<HRServiceResult<ShiftAssignmentResponse>> CreateAsync(Guid tenantId, CreateShiftAssignmentRequest request, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>> BlockShiftAssignmentAsync(Guid tenantId, CreateShiftAssignmentMultipleRequest request, CancellationToken ct);
    Task<HRServiceResult<ShiftAssignmentResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>> ListAsync(Guid tenantId, Guid branchId, DateTime? date, CancellationToken ct);
    Task<HRServiceResult<ShiftAssignmentResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateShiftAssignmentRequest request, CancellationToken ct);
    Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct);
}

public sealed class ShiftAssignmentService : IShiftAssignmentService
{
    private readonly HRDbContext _db;

    private readonly IHRNotificationHub _notificationHub;

    public ShiftAssignmentService(HRDbContext db, IHRNotificationHub notificationHub)
    {
        _db = db;
        _notificationHub = notificationHub;
    }

    public async Task<HRServiceResult<ShiftAssignmentResponse>> CreateAsync(Guid tenantId, CreateShiftAssignmentRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Fail("TenantId is required.");
        }

        if (request.EmployeeId == Guid.Empty || request.ShiftTemplateId == Guid.Empty)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Fail("EmployeeId and ShiftTemplateId are required.");
        }

        if (request.PlannedStartTimeUtc >= request.PlannedEndTimeUtc)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Fail("PlannedStartTime must be earlier than PlannedEndTime.");
        }

        var employeeExists = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == request.EmployeeId && x.TenantId == tenantId && (x.BranchId == request.BranchId || request.BranchId == null) && x.DeletedAtUtc == null, ct);

        if (employeeExists is null)
        {
            return HRServiceResult<ShiftAssignmentResponse>.NotFound("Employee not found.");
        }

        var template = await _db.ShiftTemplates
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == request.ShiftTemplateId && x.TenantId == tenantId && (x.BranchId == request.BranchId || request.BranchId == null) && x.IsActive, ct);

        if (template is null)
        {
            return HRServiceResult<ShiftAssignmentResponse>.NotFound("Shift template not found.");
        }

        //! Aynı çalışan için aynı vardiya tarih ve saatlerinde çakışan bir atama olup olmadığını kontrol validasyonu

        var assignmentsExited = await _db.ShiftAssignments.AnyAsync(x => x.TenantId == tenantId
        && (x.BranchId == request.BranchId || request.BranchId == Guid.Empty || request.BranchId == null)
        //&& x.ShiftDate == request.ShiftDate
        && (x.ShiftTemplateId == request.ShiftTemplateId || request.ShiftTemplateId == Guid.Empty)
        && x.EmployeeId == request.EmployeeId
        && (x.PlannedStartTimeUtc == request.PlannedStartTimeUtc || x.PlannedEndTimeUtc > request.PlannedStartTimeUtc)
        && (x.PlannedEndTimeUtc == request.PlannedEndTimeUtc || x.PlannedStartTimeUtc < request.PlannedEndTimeUtc), ct);

        if (assignmentsExited)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Conflict("Same shift already has been assigned.");
        }



        var now = DateTime.UtcNow;
        var assignment = new ShiftAssignment
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId ?? Guid.Empty,
            EmployeeId = request.EmployeeId,
            ShiftTemplateId = request.ShiftTemplateId,
            ShiftDate = request.ShiftDate.Date,
            PlannedStartTimeUtc = request.PlannedStartTimeUtc,
            PlannedEndTimeUtc = request.PlannedEndTimeUtc,
            Status = ShiftAssignmentStatus.Planned,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };
        try
        {
            _db.ShiftAssignments.Add(assignment);
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            // Check if the exception is due to a unique constraint violation
            if (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "23505")
            {
                return HRServiceResult<ShiftAssignmentResponse>.Conflict("Same shift already has been assigned.");
            }

            return HRServiceResult<ShiftAssignmentResponse>.Fail($"An error occurred while creating the shift assignment: {ex.Message}");

        }
        if (employeeExists.UserId == null || employeeExists.UserId == Guid.Empty)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Ok(ToResponse(assignment));
        }

        await _notificationHub.SendShiftCreateByAdmin(tenantId, employeeExists.UserId ?? Guid.Empty, assignment.Id, assignment.Status.ToString());

        return HRServiceResult<ShiftAssignmentResponse>.Ok(ToResponse(assignment));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>> BlockShiftAssignmentAsync(Guid tenantId, CreateShiftAssignmentMultipleRequest request, CancellationToken ct)
    {


        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail("TenantId is required.");
        }
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail("TenantId is required.");
        }
        if (request.EmployeeId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail("At least one EmployeeId is required.");
        }
        if (request.PlannedTimesUtc == null || !request.PlannedTimesUtc.Any())
        {
            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail("At least one planned time is required.");
        }
        var employeeExists = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == request.EmployeeId && x.TenantId == tenantId && (x.BranchId == request.BranchId || request.BranchId == null) && x.DeletedAtUtc == null, ct);
        if (employeeExists is null)
        {
            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.NotFound("Employee not found.");
        }

        using var tx = await _db.Database.BeginTransactionAsync(ct);

        foreach (var plannedTime in request.PlannedTimesUtc)
        {
            if (plannedTime.StartTimeUtc >= plannedTime.EndTimeUtc)
            {
                return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail("PlannedStartTime must be earlier than PlannedEndTime.");
            }
            var assignment = new ShiftAssignment
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = request.BranchId ?? Guid.Empty,
                EmployeeId = request.EmployeeId,
                ShiftTemplateId = null,
                ShiftDate = plannedTime.StartTimeUtc.Date,
                PlannedStartTimeUtc = plannedTime.StartTimeUtc,
                PlannedEndTimeUtc = plannedTime.EndTimeUtc,
                Status = ShiftAssignmentStatus.Planned,
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            };
            await _db.ShiftAssignments.AddAsync(assignment, ct);
        }
        try
        {
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            await tx.RollbackAsync(ct);
            // Check if the exception is due to a unique constraint violation
            if (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "23505")
            {
                return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Conflict("Same shift already has been assigned.");
            }

            return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Fail($"An error occurred while creating the shift assignments: {ex.Message}");
        }
        await _notificationHub.SendShiftCreateByAdmin(tenantId, employeeExists.UserId ?? Guid.Empty, Guid.Empty, ShiftAssignmentStatus.Planned.ToString());
        return HRServiceResult<IReadOnlyCollection<BlockShiftAssignmentResponse>>.Ok(request.PlannedTimesUtc.Select(pt => new BlockShiftAssignmentResponse(
            tenantId,
            request.EmployeeId,
            pt.StartTimeUtc,
            pt.EndTimeUtc
        )).ToList());
    }
    public async Task<HRServiceResult<ShiftAssignmentResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var assignment = await _db.ShiftAssignments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return assignment is null
            ? HRServiceResult<ShiftAssignmentResponse>.NotFound("Shift assignment not found.")
            : HRServiceResult<ShiftAssignmentResponse>.Ok(ToResponse(assignment));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>> ListAsync(Guid tenantId, Guid branchId, DateTime? date, CancellationToken ct)
    {
        var query = _db.ShiftAssignments
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId != Guid.Empty)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (date.HasValue)
        {
            var targetDate = date.Value.Date;
            query = query.Where(x => x.ShiftDate == targetDate);
        }

        var assignments = await query
            .OrderBy(x => x.PlannedStartTimeUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>.Ok(assignments.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<ShiftAssignmentResponse>> UpdateAsync(Guid tenantId, Guid id, UpdateShiftAssignmentRequest request, CancellationToken ct)
    {
        var assignment = await _db.ShiftAssignments
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (assignment is null)
        {
            return HRServiceResult<ShiftAssignmentResponse>.NotFound("Shift assignment not found.");
        }

        if (request.PlannedStartTimeUtc.HasValue)
        {
            assignment.PlannedStartTimeUtc = request.PlannedStartTimeUtc.Value;
        }

        if (request.PlannedEndTimeUtc.HasValue)
        {
            assignment.PlannedEndTimeUtc = request.PlannedEndTimeUtc.Value;
        }

        if (assignment.PlannedStartTimeUtc >= assignment.PlannedEndTimeUtc)
        {
            return HRServiceResult<ShiftAssignmentResponse>.Fail("PlannedStartTime must be earlier than PlannedEndTime.");
        }

        assignment.ActualStartTimeUtc = request.ActualStartTimeUtc ?? assignment.ActualStartTimeUtc;
        assignment.ActualEndTimeUtc = request.ActualEndTimeUtc ?? assignment.ActualEndTimeUtc;

        if (request.Status.HasValue)
        {
            assignment.Status = request.Status.Value;
        }

        assignment.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<ShiftAssignmentResponse>.Ok(ToResponse(assignment));
    }

    public async Task<HRServiceResult<bool>> DeleteAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var assignment = await _db.ShiftAssignments
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        if (assignment is null)
        {
            return HRServiceResult<bool>.NotFound("Shift assignment not found.");
        }

        _db.ShiftAssignments.Remove(assignment);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<bool>.Ok(true);
    }

    private static ShiftAssignmentResponse ToResponse(ShiftAssignment assignment)
        => new(
            assignment.Id,
            assignment.TenantId,
            assignment.BranchId,
            assignment.EmployeeId,
            assignment.ShiftTemplateId ?? Guid.Empty,
            assignment.ShiftDate,
            assignment.PlannedStartTimeUtc,
            assignment.PlannedEndTimeUtc,
            assignment.ActualStartTimeUtc,
            assignment.ActualEndTimeUtc,
            assignment.Status,
            assignment.CreatedAtUtc,
            assignment.UpdatedAtUtc);

    private static List<BlockShiftAssignmentResponse> ToBlockResponse(ShiftAssignment assignment)
       => new List<BlockShiftAssignmentResponse>
       {
           new BlockShiftAssignmentResponse(
               assignment.TenantId,
               assignment.EmployeeId,
               assignment.PlannedStartTimeUtc,
               assignment.PlannedEndTimeUtc
           )
       };
}
