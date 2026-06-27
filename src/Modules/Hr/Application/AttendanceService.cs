using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;
using Npgsql;

namespace Modules.HR.Application;

public interface IAttendanceService
{
    Task<HRServiceResult<AttendanceResponse>> CheckInAsync(Guid tenantId, CreateAttendanceCheckInRequest request, CancellationToken ct);
    Task<HRServiceResult<AttendanceResponse>> CheckOutAsync(Guid tenantId, CreateAttendanceCheckOutRequest request, CancellationToken ct);
    Task<HRServiceResult<AttendanceResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>> GetMyShiftsAsync(Guid tenantId, Guid userId, CancellationToken ct);
    Task<HRServiceResult<AttendanceLatenessResponse>> GetLatenessAsync(Guid tenantId, Guid attendanceId, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<AttendanceResponse>>> ListByDateAsync(Guid tenantId, Guid branchId, DateTime date, CancellationToken ct);
}

public sealed class AttendanceService : IAttendanceService
{
    private readonly HRDbContext _db;

    private readonly ILogger<AttendanceService> _logger;
    

    public AttendanceService(HRDbContext db, ILogger<AttendanceService> logger)
    {
        _db = db;
        _logger = logger;
    }


    public async Task<HRServiceResult<AttendanceResponse>> CheckInAsync(Guid tenantId, CreateAttendanceCheckInRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("TenantId is required.");
        }

        if (request.UserId == Guid.Empty || request.ShiftAssignmentId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("UserId and ShiftAssignmentId are required.");
        }

        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == request.UserId && x.TenantId == tenantId, ct);

        if (employee is null)
        {
            return HRServiceResult<AttendanceResponse>.NotFound("Employee not found.");
        }

        var assignment = await _db.ShiftAssignments
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.ShiftAssignmentId &&
                x.TenantId == tenantId &&
                (x.BranchId == request.BranchId || x.BranchId == Guid.Empty) &&
                x.Status != ShiftAssignmentStatus.Completed &&
                x.Status != ShiftAssignmentStatus.Cancelled &&
                x.EmployeeId == employee.Id,
                ct);

        if (assignment is null)
        {
            return HRServiceResult<AttendanceResponse>.NotFound("Shift assignment not found.");
        }

        var alreadyExists = await _db.AttendanceRecords
            .AsNoTracking()
            .AnyAsync(x => x.TenantId == tenantId && x.ShiftAssignmentId == request.ShiftAssignmentId, ct);

        if (alreadyExists)
        {
            return HRServiceResult<AttendanceResponse>.Conflict("Attendance record already exists for this shift assignment.");
        }
        using var tx = await _db.Database.BeginTransactionAsync(ct);

        assignment.ActualStartTimeUtc = DateTime.UtcNow;
        assignment.Status = ShiftAssignmentStatus.CheckedIn;

        var checkInTime = DateTime.UtcNow;
        var now = DateTime.UtcNow;


        var attendance = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId ?? assignment.BranchId,
            EmployeeId = employee.Id,
            ShiftAssignmentId = request.ShiftAssignmentId,
            ShiftDate = assignment.ShiftDate.Date,
            PlannedStartTimeUtc = assignment.PlannedStartTimeUtc,
            PlannedEndTimeUtc = assignment.PlannedEndTimeUtc,
            CheckInTimeUtc = checkInTime,
            Status = checkInTime <= assignment.PlannedStartTimeUtc ? AttendanceStatus.OnTime : AttendanceStatus.Late,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        try
        {
            _db.AttendanceRecords.Add(attendance);
            _db.ShiftAssignments.Update(assignment);
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            if (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "23505")
            {
                await tx.RollbackAsync(ct);
                return HRServiceResult<AttendanceResponse>.Conflict("Attendance record already exists for this shift assignment.");
            }
            await tx.RollbackAsync(ct); 

            return HRServiceResult<AttendanceResponse>.Fail("Unexpected database error while creating attendance.");
        }
        await tx.CommitAsync(ct);

        return HRServiceResult<AttendanceResponse>.Ok(ToResponse(attendance));
    }

    public async Task<HRServiceResult<AttendanceResponse>> CheckOutAsync(Guid tenantId,  CreateAttendanceCheckOutRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("TenantId is required.");
        }
        if (request.UserId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("UserId is required.");
        }
        if (request.ShiftAssignmentId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("ShiftAssignmentId is required.");
        }
        var shift = await _db.ShiftAssignments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == request.ShiftAssignmentId && x.TenantId == tenantId, ct);
        if (shift is null)        {
            return HRServiceResult<AttendanceResponse>.NotFound("Shift assignment not found.");
        }
        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == request.UserId && x.TenantId == tenantId, ct);
        if (employee is null)
        {
            return HRServiceResult<AttendanceResponse>.NotFound("Employee not found.");
        }

        var attendance = await _db.AttendanceRecords
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.ShiftAssignmentId == request.ShiftAssignmentId &&
                x.EmployeeId == employee.Id
                && x.CheckInTimeUtc != null 
                && x.CheckOutTimeUtc == null, ct);

        if (attendance is null)        {
            return HRServiceResult<AttendanceResponse>.NotFound("Attendance record not found for this shift assignment.");
        }
        using var tx = await _db.Database.BeginTransactionAsync(ct);
        
        var checkOutTime = request.CheckOutTimeUtc ?? DateTime.UtcNow;

        if (attendance.CheckInTimeUtc.HasValue && checkOutTime < attendance.CheckInTimeUtc.Value)
        {
            return HRServiceResult<AttendanceResponse>.Fail("CheckOutTime cannot be earlier than CheckInTime.");
        }

        attendance.CheckOutTimeUtc = checkOutTime;
        attendance.Status = checkOutTime < attendance.PlannedEndTimeUtc
            ? AttendanceStatus.EarlyLeave
            : AttendanceStatus.OnTime;
        attendance.UpdatedAtUtc = DateTime.UtcNow;

        _db.AttendanceRecords.Update(attendance);

        shift.ActualEndTimeUtc = checkOutTime;
        if (shift.Status != ShiftAssignmentStatus.Cancelled)
        {
            shift.Status = ShiftAssignmentStatus.Completed;
        }
        _db.ShiftAssignments.Update(shift);
        try
        {            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync(ct);
            return HRServiceResult<AttendanceResponse>.Fail("Unexpected database error while updating attendance.");
        }
        await tx.CommitAsync(ct);

        return HRServiceResult<AttendanceResponse>.Ok(ToResponse(attendance));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>> GetMyShiftsAsync(Guid tenantId, Guid userId, CancellationToken ct)
    {
        _logger.LogInformation("Fetching shifts for user {UserId} in tenant {TenantId}", userId, tenantId);

        
        var employee = await _db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == userId && x.TenantId == tenantId, ct);

        if (employee is null)
        {
            return HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>.NotFound("Employee not found.");
        }

        var shifts = await _db.ShiftAssignments
            .AsNoTracking()
            .Where(x => x.EmployeeId == employee.Id && x.TenantId == tenantId)
            .OrderBy(x => x.PlannedStartTimeUtc)
            .ToListAsync(ct);

        

        return HRServiceResult<IReadOnlyCollection<ShiftAssignmentResponse>>.Ok(shifts.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<AttendanceResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var attendance = await _db.AttendanceRecords
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return attendance is null
            ? HRServiceResult<AttendanceResponse>.NotFound("Attendance record not found.")
            : HRServiceResult<AttendanceResponse>.Ok(ToResponse(attendance));
    }

    public async Task<HRServiceResult<AttendanceLatenessResponse>> GetLatenessAsync(Guid tenantId, Guid attendanceId, CancellationToken ct)
    {
        var attendance = await _db.AttendanceRecords
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == attendanceId && x.TenantId == tenantId, ct);

        if (attendance is null)
        {
            return HRServiceResult<AttendanceLatenessResponse>.NotFound("Attendance record not found.");
        }

        if (!attendance.CheckInTimeUtc.HasValue)
        {
            return HRServiceResult<AttendanceLatenessResponse>.Ok(new AttendanceLatenessResponse(
                attendance.Id,
                attendance.EmployeeId,
                attendance.ShiftDate,
                attendance.PlannedStartTimeUtc,
                attendance.CheckInTimeUtc,
                false,
                0));
        }

        var lateDuration = attendance.CheckInTimeUtc.Value - attendance.PlannedStartTimeUtc;
        var isLate = lateDuration > TimeSpan.Zero;
        var lateByMinutes = isLate ? (int)Math.Floor(lateDuration.TotalMinutes) : 0;

        return HRServiceResult<AttendanceLatenessResponse>.Ok(new AttendanceLatenessResponse(
            attendance.Id,
            attendance.EmployeeId,
            attendance.ShiftDate,
            attendance.PlannedStartTimeUtc,
            attendance.CheckInTimeUtc,
            isLate,
            lateByMinutes));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<AttendanceResponse>>> ListByDateAsync(Guid tenantId, Guid branchId, DateTime date, CancellationToken ct)
    {
        if (branchId == Guid.Empty)
        {
            return HRServiceResult<IReadOnlyCollection<AttendanceResponse>>.Fail("BranchId is required.");
        }

        var targetDate = date.Date;

        var attendances = await _db.AttendanceRecords
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BranchId == branchId && x.ShiftDate == targetDate)
            .OrderBy(x => x.PlannedStartTimeUtc)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<AttendanceResponse>>.Ok(attendances.Select(ToResponse).ToList());
    }

    private static AttendanceResponse ToResponse(AttendanceRecord attendance)
        => new(
            attendance.Id,
            attendance.TenantId,
            attendance.BranchId,
            attendance.EmployeeId,
            attendance.ShiftAssignmentId,
            attendance.ShiftDate,
            attendance.PlannedStartTimeUtc,
            attendance.PlannedEndTimeUtc,
            attendance.CheckInTimeUtc,
            attendance.CheckOutTimeUtc,
            attendance.Status,
            attendance.CreatedAtUtc,
            attendance.UpdatedAtUtc);
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
}
