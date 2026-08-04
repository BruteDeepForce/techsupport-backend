using Microsoft.EntityFrameworkCore;
using TechSupport.Trade.Domain.Entities;

namespace TechSupport.Trade.Data;

public sealed class TradeDbContext : DbContext
{
    public TradeDbContext(DbContextOptions<TradeDbContext> options) : base(options)
    {
    }

    public DbSet<QuickSale> QuickSales => Set<QuickSale>();
    public DbSet<QuickSaleLine> QuickSaleLines => Set<QuickSaleLine>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("trade");

        modelBuilder.Entity<QuickSale>(b =>
        {
            b.ToTable("quick_sales");
            b.HasKey(x => x.Id);
            b.Property(x => x.SaleNumber).HasMaxLength(64).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            b.Property(x => x.Currency).HasMaxLength(8).IsRequired();
            b.Property(x => x.PaymentMethod).HasMaxLength(32).IsRequired();
            b.Property(x => x.Note).HasMaxLength(512);
            b.Property(x => x.SubtotalAmount).HasPrecision(18, 2);
            b.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            b.Property(x => x.TotalAmount).HasPrecision(18, 2);
            b.Property(x => x.PaidAmount).HasPrecision(18, 2);
            b.HasIndex(x => new { x.TenantId, x.SaleNumber }).IsUnique();
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
            b.HasIndex(x => new { x.QuickSaleId, x.StockItemId });
        });

        base.OnModelCreating(modelBuilder);
    }
}
