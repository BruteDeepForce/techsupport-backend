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
    public DbSet<QuickSale> QuickSales => Set<QuickSale>();
    public DbSet<QuickSaleLine> QuickSaleLines => Set<QuickSaleLine>();

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

        modelBuilder.Entity<QuickSale>(b =>
        {
            b.ToTable("quick_sales");
            b.HasKey(x => x.Id);
            b.Property(x => x.SaleNumber).HasMaxLength(64).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
            b.Property(x => x.SubtotalAmount).HasPrecision(18, 2);
            b.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            b.Property(x => x.TotalAmount).HasPrecision(18, 2);
            b.Property(x => x.PaidAmount).HasPrecision(18, 2);
            b.Property(x => x.Currency).HasMaxLength(10).IsRequired();
            b.Property(x => x.PaymentMethod).HasMaxLength(64).IsRequired();
            b.Property(x => x.Note).HasMaxLength(1000);
            b.HasIndex(x => new { x.TenantId, x.CreatedAtUtc });
            b.HasIndex(x => new { x.TenantId, x.Status });
            b.HasMany(x => x.Lines)
                .WithOne(x => x.QuickSale)
                .HasForeignKey(x => x.QuickSaleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<QuickSaleLine>(b =>
        {
            b.ToTable("quick_sale_lines");
            b.HasKey(x => x.Id);
            b.Property(x => x.ProductName).HasMaxLength(256).IsRequired();
            b.Property(x => x.Sku).HasMaxLength(128).IsRequired();
            b.Property(x => x.UnitPrice).HasPrecision(18, 2);
            b.Property(x => x.LineTotal).HasPrecision(18, 2);
            b.HasIndex(x => x.QuickSaleId);
        });

        base.OnModelCreating(modelBuilder);
    }
}
