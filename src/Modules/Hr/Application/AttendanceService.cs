using Microsoft.EntityFrameworkCore;
using Modules.HR.Domain;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;
using Npgsql;

namespace Modules.HR.Application;

public interface IAttendanceService
{
    Task<HRServiceResult<AttendanceResponse>> CheckInAsync(Guid tenantId, CreateAttendanceCheckInRequest request, CancellationToken ct);
    Task<HRServiceResult<AttendanceResponse>> CheckOutAsync(Guid tenantId, Guid attendanceId, CreateAttendanceCheckOutRequest request, CancellationToken ct);
    Task<HRServiceResult<AttendanceResponse>> GetByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<AttendanceLatenessResponse>> GetLatenessAsync(Guid tenantId, Guid attendanceId, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<AttendanceResponse>>> ListByDateAsync(Guid tenantId, Guid branchId, DateTime date, CancellationToken ct);
}

public sealed class AttendanceService : IAttendanceService
{
    private readonly HRDbContext _db;

    public AttendanceService(HRDbContext db)
    {
        _db = db;
    }

    public async Task<HRServiceResult<AttendanceResponse>> CheckInAsync(Guid tenantId, CreateAttendanceCheckInRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty || request.BranchId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("TenantId and BranchId are required.");
        }

        if (request.EmployeeId == Guid.Empty || request.ShiftAssignmentId == Guid.Empty)
        {
            return HRServiceResult<AttendanceResponse>.Fail("EmployeeId and ShiftAssignmentId are required.");
        }

        var assignment = await _db.ShiftAssignments
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.ShiftAssignmentId &&
                x.TenantId == tenantId &&
                x.BranchId == request.BranchId &&
                x.EmployeeId == request.EmployeeId,
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

        var checkInTime = request.CheckInTimeUtc ?? DateTime.UtcNow;
        var now = DateTime.UtcNow;

        var attendance = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = request.BranchId,
            EmployeeId = request.EmployeeId,
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
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            if (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "23505")
            {
                return HRServiceResult<AttendanceResponse>.Conflict("Attendance record already exists for this shift assignment.");
            }

            return HRServiceResult<AttendanceResponse>.Fail("Unexpected database error while creating attendance.");
        }

        return HRServiceResult<AttendanceResponse>.Ok(ToResponse(attendance));
    }

    public async Task<HRServiceResult<AttendanceResponse>> CheckOutAsync(Guid tenantId, Guid attendanceId, CreateAttendanceCheckOutRequest request, CancellationToken ct)
    {
        var attendance = await _db.AttendanceRecords
            .FirstOrDefaultAsync(x => x.Id == attendanceId && x.TenantId == tenantId, ct);

        if (attendance is null)
        {
            return HRServiceResult<AttendanceResponse>.NotFound("Attendance record not found.");
        }

        if (attendance.CheckOutTimeUtc.HasValue)
        {
            return HRServiceResult<AttendanceResponse>.Conflict("Check-out already completed.");
        }

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

        await _db.SaveChangesAsync(ct);

        return HRServiceResult<AttendanceResponse>.Ok(ToResponse(attendance));
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
}
