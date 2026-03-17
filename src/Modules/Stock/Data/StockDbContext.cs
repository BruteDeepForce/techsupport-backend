using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Domain.Entities;

namespace TechSupport.Stock.Data;

public class StockDbContext : DbContext
{
    public StockDbContext(DbContextOptions<StockDbContext> options) : base(options)
    {
    }

    public DbSet<StockItem> StockItems { get; set; }
    public DbSet<StockBalance> StockBalances { get; set; }
    public DbSet<StockTransaction> StockTransactions { get; set; }
    public DbSet<StockReservation> StockReservations { get; set; }
    public DbSet<TechSupport.Stock.Domain.Entities.StockCategories> StockCategories { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // place all stock module tables in the dedicated Postgres schema 'stock'
        modelBuilder.HasDefaultSchema("stock");

        modelBuilder.Entity<StockItem>(b =>
        {
            b.ToTable("stock_items");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.Sku }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.Barcode }).IsUnique();
            b.Property(x => x.CategoryId).IsRequired(false);

            // relation: StockItem -> StockCategories (many items may reference one category)
            b.HasOne(x => x.Category)
             .WithMany(c => c.StockItems)
             .HasForeignKey(x => x.CategoryId)
             .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<TechSupport.Stock.Domain.Entities.StockCategories>(b =>
        {
            b.ToTable("stock_categories");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(256).IsRequired();
            b.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();
        });

        modelBuilder.Entity<StockBalance>(b =>
        {
            b.ToTable("stock_balances");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.StockItemId, x.BranchId }).IsUnique();
            b.Property(x => x.RowVersion).IsRowVersion();

            // relation: StockBalance -> StockItem (many balances for one item), cascade on delete
            b.HasOne(x => x.StockItem)
             .WithMany(i => i.Balances)
             .HasForeignKey(x => x.StockItemId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<StockTransaction>(b =>
        {
            b.ToTable("stock_transactions");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.StockItemId });

            // optional navigation; keep transactions for audit - do not cascade by default
            b.HasOne(x => x.StockItem)
             .WithMany(i => i.Transactions)
             .HasForeignKey(x => x.StockItemId)
             .OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<StockReservation>(b =>
        {
            b.ToTable("stock_reservations");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.OperationId });

            b.HasOne(x => x.StockItem)
             .WithMany(i => i.Reservations)
             .HasForeignKey(x => x.StockItemId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
