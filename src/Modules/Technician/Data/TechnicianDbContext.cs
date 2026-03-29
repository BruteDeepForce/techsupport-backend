using Microsoft.EntityFrameworkCore;
using TechSupport.Technician.Domain.Entities;

namespace TechSupport.Technician.Data;

public sealed class TechnicianDbContext : DbContext
{
    public TechnicianDbContext(DbContextOptions<TechnicianDbContext> options) : base(options)
    {
    }

    public DbSet<Technician.Domain.Entities.Technician> Technicians => Set<Technician.Domain.Entities.Technician>();
    public DbSet<TechnicianProvisionRequest> TechnicianProvisionRequests => Set<TechnicianProvisionRequest>();
    public DbSet<Technician.Domain.Entities.TechnicianOperation> TechnicianOperations => Set<Technician.Domain.Entities.TechnicianOperation>();

    public DbSet<TechnicianExpert> TechnicianExperts => Set<TechnicianExpert>();
    public DbSet<TechnicianExpertMapping> TechnicianExpertMappings => Set<TechnicianExpertMapping>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("technicians");

        modelBuilder.Entity<Technician.Domain.Entities.Technician>(b =>
        {
            b.ToTable("technicians");
            b.HasKey(x => x.Id);
            b.Property(x => x.AppUserId).IsRequired(false);
            b.Property(x => x.FirstName).HasMaxLength(100).IsRequired();
            b.Property(x => x.Email).HasMaxLength(320).IsRequired();
            b.Property(x => x.PhoneNumber).HasMaxLength(32);
            b.HasIndex(x => new { x.TenantId, x.Email }).IsUnique();
            b.HasIndex(x => x.AppUserId).IsUnique();
        });

        modelBuilder.Entity<TechnicianProvisionRequest>(b =>
        {
            b.ToTable("technician_provision_requests");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(100).IsRequired();
            b.Property(x => x.Email).HasMaxLength(320).IsRequired();
            b.Property(x => x.PhoneNumber).HasMaxLength(32);
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            b.Property(x => x.FailureReason).HasMaxLength(1000);
            b.HasIndex(x => x.CorrelationId).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.Email });
        });

        modelBuilder.Entity<Technician.Domain.Entities.TechnicianOperation>(b =>
        {
            b.ToTable("technician_operations");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.OperationId });
            b.Property(x => x.Title).HasMaxLength(256).IsRequired();
            b.Property(x => x.Description).HasMaxLength(4000);
            b.Property(x => x.Status).HasMaxLength(50).IsRequired();
            b.Property(x=> x.Status).HasConversion<string>();
        });

        modelBuilder.Entity<TechnicianExpertMapping>(b =>
        {
            b.ToTable("technician_expert_mappings");
            b.HasKey(x => new { x.TechnicianId, x.TechnicianExpertId, x.tenantId });
            b.HasOne(x => x.Technician)
                .WithMany(t => t.TechnicianExpertMappings)
                .HasForeignKey(x => x.TechnicianId)
                .OnDelete(DeleteBehavior.Cascade);
            b.HasOne(x => x.TechnicianExpert)
                .WithMany(t => t.TechnicianExpertMappings)
                .HasForeignKey(x => x.TechnicianExpertId)
                .OnDelete(DeleteBehavior.Cascade);
        });



        base.OnModelCreating(modelBuilder);
    }
}
