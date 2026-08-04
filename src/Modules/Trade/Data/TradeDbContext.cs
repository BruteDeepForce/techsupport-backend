using Microsoft.EntityFrameworkCore;
using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Data;

public sealed class TradeDbContext : DbContext
{
    public TradeDbContext(DbContextOptions<TradeDbContext> options) : base(options)
    {
    }

    public DbSet<TradeRecord> Trades => Set<TradeRecord>();
    public DbSet<DeviceRegisteration> DeviceRegisterations => Set<DeviceRegisteration>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("trade");

        modelBuilder.Entity<TradeRecord>(b =>
        {
            b.ToTable("trades");
            b.HasKey(x => x.Id);
            b.Property(x => x.CustomerId);
            b.Property(x => x.DeviceId);

            b.Property(x => x.Type).HasConversion<string>().HasMaxLength(20).IsRequired();
            b.Property(x => x.PaymentMethod).HasConversion<string>().HasMaxLength(20).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20).IsRequired();

            b.Property(x => x.ImeiOrSerial).HasMaxLength(64);
            b.Property(x => x.Notes).HasMaxLength(1000);
            b.Property(x => x.IdempotencyKey).HasMaxLength(256).IsRequired();
            b.Property(x => x.UnitPrice).HasPrecision(18, 2);
            b.Property(x => x.CostPrice).HasPrecision(18, 2);
            b.Property(x => x.TotalAmount).HasPrecision(18, 2);
            b.Property(x => x.PaidAmount).HasPrecision(18, 2);

            b.HasIndex(x => new { x.TenantId, x.CreatedAtUtc });
            b.HasIndex(x => new { x.TenantId, x.Status });
            b.HasIndex(x => new { x.TenantId, x.Type });
            b.HasIndex(x => new { x.TenantId, x.ImeiOrSerial });
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            b.HasIndex(x => new { x.TenantId, x.DeviceId });
            b.HasIndex(x => new { x.TenantId, x.IdempotencyKey }).IsUnique();

            b.HasOne(x => x.DeviceInfo)
                .WithOne(x => x.Trade)
                .HasForeignKey<DeviceRegisteration>(x => x.TradeId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<DeviceRegisteration>(b =>
        {
            b.ToTable("device_registerations");
            b.HasKey(x => x.Id);
            b.Property(x => x.TradeId).IsRequired();
            b.Property(x => x.IdempotencyKey).HasMaxLength(256).IsRequired();
            b.Property(x => x.Brand).HasMaxLength(128).IsRequired();
            b.Property(x => x.Model).HasMaxLength(128).IsRequired();
            b.Property(x => x.SerialNumber).HasMaxLength(128).IsRequired();
            b.Property(x => x.ProblemDescription).HasMaxLength(4000);
            b.Property(x => x.BarcodeNumber).HasMaxLength(128);
            b.Property(x => x.CustomerName).HasMaxLength(200);
            b.Property(x => x.Status).HasMaxLength(64);
            b.HasIndex(x => x.TradeId).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.IdempotencyKey }).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}
