using Microsoft.EntityFrameworkCore;
using TechSupport.Device.Domain.Entities;

namespace TechSupport.Device.Data;

public sealed class DeviceDbContext : DbContext
{
    public DeviceDbContext(DbContextOptions<DeviceDbContext> options) : base(options)
    {
    }

    public DbSet<Devices> Devices => Set<Devices>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("devices");

        modelBuilder.Entity<Devices>(b =>
        {
            b.ToTable("devices");
            b.HasKey(x => x.Id);

            b.Property(x => x.Brand).HasMaxLength(128).IsRequired();
            b.Property(x => x.Model).HasMaxLength(128).IsRequired();
            b.Property(x => x.SerialNumber).HasMaxLength(128).IsRequired();
            b.Property(x => x.ProblemDescription).HasMaxLength(4000);
            b.Property(x => x.GuaranteePeriod).HasDefaultValue(0);

            b.HasIndex(x => new { x.TenantId, x.SerialNumber }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.BranchId });
        });

        base.OnModelCreating(modelBuilder);
    }
}
