using System.Security.Cryptography.X509Certificates;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Modules.HR.Domain;
using Modules.HR.Domain.Bordro;

namespace Modules.HR.Infrastructure;

public class HRDbContext : DbContext
{
    public HRDbContext(DbContextOptions<HRDbContext> options) : base(options)
    {
    }

    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<Position> Positions => Set<Position>();
    public DbSet<ShiftTemplate> ShiftTemplates => Set<ShiftTemplate>();
    public DbSet<ShiftAssignment> ShiftAssignments => Set<ShiftAssignment>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<Advance> Advances => Set<Advance>();
    public DbSet<Leave> Leaves => Set<Leave>();
    public DbSet<LeaveDeduction> LeaveDeductions => Set<LeaveDeduction>();

    public DbSet<BordroEmployee> BordroEmployees => Set<BordroEmployee>();
    public DbSet<BordroDonem> BordroDonems => Set<BordroDonem>();
    public DbSet<BordroKalem> BordroKalems => Set<BordroKalem>();
    public DbSet<BordroComponent> BordroComponents => Set<BordroComponent>();
    public DbSet<EmployeeSalary> EmployeeSalaries => Set<EmployeeSalary>();

    public DbSet<Discipline> Disciplines => Set<Discipline>();
    public DbSet<DisciplineEmployeeRecord> DisciplineEmployeeRecords => Set<DisciplineEmployeeRecord>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<RewardEmployeeRecord> RewardEmployeeRecords => Set<RewardEmployeeRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasDefaultSchema("hr");

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeNo).HasMaxLength(64).IsRequired();
            entity.Property(x => x.FullName).HasMaxLength(256).IsRequired();
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.Phone).HasMaxLength(32);
            entity.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.EmployeeNo }).IsUnique();
            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.Status });
            entity.HasIndex(x => new { x.TenantId, x.PositionId });
            entity.HasIndex(x => new { x.TenantId, x.DepartmentId });
            entity.HasOne(x => x.Department).WithMany(x => x.Employees).HasForeignKey(x => x.DepartmentId);
            entity.HasOne(x => x.Position).WithMany(x => x.Employees).HasForeignKey(x => x.PositionId).OnDelete(DeleteBehavior.SetNull);
        
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Code).HasMaxLength(64);
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();
            entity.HasMany(x => x.Employees).WithOne(x => x.Department).HasForeignKey(x => x.DepartmentId);
            entity.HasMany(x => x.BordroEmployees).WithOne(x => x.Department).HasForeignKey(x => x.DepartmentId);
        });

        modelBuilder.Entity<Position>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(128).IsRequired();
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();


            entity.HasMany(x => x.Employees).WithOne(x => x.Position).HasForeignKey(x => x.PositionId).OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<ShiftTemplate>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(128).IsRequired();
            entity.Property(x => x.StartTime).IsRequired();
            entity.Property(x => x.EndTime).IsRequired();
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.IsNightShift).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.Name }).IsUnique();
        });

        modelBuilder.Entity<ShiftAssignment>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.ShiftTemplateId).IsRequired();
            entity.Property(x => x.ShiftDate).IsRequired();
            entity.Property(x => x.PlannedStartTimeUtc).IsRequired();
            entity.Property(x => x.PlannedEndTimeUtc).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();
            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.EmployeeId, x.ShiftTemplateId, x.ShiftDate, x.PlannedStartTimeUtc }).IsUnique();
            //! güvenli atomc insert için şimdilik plannedstart time'a unique index ekledim. İleride ihtiyaç olursa planned end time da eklenebilir. 
        });

        modelBuilder.Entity<AttendanceRecord>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.ShiftAssignmentId).IsRequired();
            entity.Property(x => x.ShiftDate).IsRequired();
            entity.Property(x => x.PlannedStartTimeUtc).IsRequired();
            entity.Property(x => x.PlannedEndTimeUtc).IsRequired();
            entity.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.ShiftAssignmentId }).IsUnique();
            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.ShiftDate, x.EmployeeId });

            entity.HasOne<ShiftAssignment>()
                .WithMany()
                .HasForeignKey(x => x.ShiftAssignmentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Leave>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.DepartmentId);
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.StartDate).IsRequired();
            entity.Property(x => x.EndDate).IsRequired();
            entity.Property(x => x.Type).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(x => x.Reason).HasMaxLength(512);
            entity.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.EmployeeId, x.StartDate, x.EndDate });
            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.DepartmentId, x.StartDate });

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.EmployeeLeaves)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(x => x.Department)
                .WithMany()
                .HasForeignKey(x => x.DepartmentId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(x => x.LeaveDeduction)
                .WithMany(x => x.Leaves)
                .HasForeignKey(x => x.LeaveDeductionId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<LeaveDeduction>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(512).IsRequired();
            entity.Property(x => x.DeductionAmount).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.CreatedAtUtc });

            entity.HasMany(x => x.Leaves)
                .WithOne(x => x.LeaveDeduction)
                .HasForeignKey(x => x.LeaveDeductionId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Advance>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.DepartmentId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.Amount).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.Reason).HasMaxLength(512);
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.EmployeeId, x.CreatedAtUtc });
            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.DepartmentId, x.CreatedAtUtc });

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.EmployeeAdvances)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(x => x.Department)
                .WithMany()
                .HasForeignKey(x => x.DepartmentId)
                .OnDelete(DeleteBehavior.SetNull);
        });


        modelBuilder.Entity<BordroDonem>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Year).IsRequired();
            entity.Property(x => x.Month).IsRequired();
            entity.Property(x => x.BaslangicTarihi).IsRequired();
            entity.Property(x => x.BitisTarihi).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.Year, x.Month }).IsUnique();

            entity.HasMany(x => x.BordroEmployees)
                .WithOne(x => x.BordroDonem)
                .HasForeignKey(x => x.BordroDonemId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<BordroEmployee>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.DepartmentId).IsRequired();
            entity.Property(x => x.BordroDonemId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.EmployeeName).HasMaxLength(256).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.EmployeeId });

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.BordroEmployees)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasMany(x => x.BordroKalems)
                .WithOne(x => x.BordroEmployee)
                .HasForeignKey(x => x.BordroEmployeeId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<BordroKalem>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.BordroEmployeeId).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(256).IsRequired();
            entity.Property(x => x.Amount).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.Type).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.BordroEmployeeId, x.CreatedAtUtc });

            entity.HasOne(x => x.BordroEmployee)
                .WithMany(x => x.BordroKalems)
                .HasForeignKey(x => x.BordroEmployeeId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<BordroComponent>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Code).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Type).HasConversion<string>().HasMaxLength(32).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.BranchId, x.Code }).IsUnique();

             entity.HasMany(x => x.BordroKalems)
                .WithOne(x => x.BordroComponent)
                .HasForeignKey(x => x.BordroComponentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<EmployeeSalary>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.GrossSalary).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.NetSalary).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.EffectiveFrom).IsRequired();
            entity.Property(x => x.EffectiveTo);
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasIndex(x => new { x.TenantId, x.EmployeeId, x.EffectiveFrom }).IsUnique();

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.EmployeeSalaries)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.Cascade);
            });

        modelBuilder.Entity<Discipline>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(512).IsRequired();
            entity.Property(x => x.PenaltyAmount).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();
        });

        modelBuilder.Entity<DisciplineEmployeeRecord>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.DisciplineId).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.DisciplineEmployeeRecords)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(x => x.Discipline)
                .WithMany(x => x.DisciplineEmployeeRecords)
                .HasForeignKey(x => x.DisciplineId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Reward>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(512).IsRequired();
            entity.Property(x => x.RewardAmount).HasColumnType("numeric(18,2)").IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();
        });

        modelBuilder.Entity<RewardEmployeeRecord>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).IsRequired();
            entity.Property(x => x.BranchId).IsRequired();
            entity.Property(x => x.EmployeeId).IsRequired();
            entity.Property(x => x.RewardId).IsRequired();
            entity.Property(x => x.CreatedAtUtc).IsRequired();

            entity.HasOne(x => x.Employee)
                .WithMany(x => x.RewardEmployeeRecords)
                .HasForeignKey(x => x.EmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(x => x.Reward)
                .WithMany(x => x.RewardEmployeeRecords)
                .HasForeignKey(x => x.RewardId)
                .OnDelete(DeleteBehavior.SetNull);
        });
    }


}
