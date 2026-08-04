using Microsoft.EntityFrameworkCore;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.Outbox;

namespace TechSupport.Trade.Data;

public sealed class TradeDbContext : DbContext
{
    public TradeDbContext(DbContextOptions<TradeDbContext> options) : base(options)
    {
    }

    public DbSet<TradeRecord> Trades => Set<TradeRecord>();
    public DbSet<DeviceRegisteration> DeviceRegisterations => Set<DeviceRegisteration>();
    public DbSet<QuickSale> QuickSales => Set<QuickSale>();
    public DbSet<QuickSaleItem> QuickSaleItems => Set<QuickSaleItem>();
    public DbSet<TradeOutboxMessage> OutboxMessages => Set<TradeOutboxMessage>();
    public DbSet<TradeInboxMessage> InboxMessages => Set<TradeInboxMessage>();

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
            b.Property(x => x.IdempotencyKey).HasMaxLength(256).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            b.Property(x => x.PaymentMethod).HasConversion<string>().HasMaxLength(20).IsRequired();
            b.Property(x => x.Subtotal).HasPrecision(18, 2);
            b.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            b.Property(x => x.TotalAmount).HasPrecision(18, 2);
            b.Property(x => x.PaidAmount).HasPrecision(18, 2);
            b.Property(x => x.FailureReason).HasMaxLength(2000);
            b.HasIndex(x => new { x.TenantId, x.IdempotencyKey }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.SaleNumber }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.BranchId, x.CreatedAtUtc });
            b.HasMany(x => x.Items)
                .WithOne(x => x.QuickSale)
                .HasForeignKey(x => x.QuickSaleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<QuickSaleItem>(b =>
        {
            b.ToTable("quick_sale_items");
            b.HasKey(x => x.Id);
            b.Property(x => x.ProductNameSnapshot).HasMaxLength(256).IsRequired();
            b.Property(x => x.SkuSnapshot).HasMaxLength(128).IsRequired();
            b.Property(x => x.BarcodeSnapshot).HasMaxLength(128);
            b.Property(x => x.UnitPriceSnapshot).HasPrecision(18, 2);
            b.Property(x => x.LineTotal).HasPrecision(18, 2);
            b.HasIndex(x => new { x.QuickSaleId, x.StockItemId }).IsUnique();
        });

        modelBuilder.Entity<TradeOutboxMessage>(b =>
        {
            b.ToTable("outbox_messages");
            b.HasKey(x => x.Id);
            b.Property(x => x.EventType).HasMaxLength(1000).IsRequired();
            b.Property(x => x.Payload).HasColumnType("jsonb").IsRequired();
            b.Property(x => x.LastError).HasMaxLength(4000);
            b.HasIndex(x => x.MessageId).IsUnique();
            b.HasIndex(x => new { x.ProcessedAtUtc, x.NextAttemptAtUtc });
        });

        modelBuilder.Entity<TradeInboxMessage>(b =>
        {
            b.ToTable("inbox_messages");
            b.HasKey(x => x.Id);
            b.Property(x => x.ConsumerName).HasMaxLength(300).IsRequired();
            b.HasIndex(x => new { x.ConsumerName, x.MessageId }).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}
