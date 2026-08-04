using Microsoft.EntityFrameworkCore;
using TechSupport.Account.Domain.Entities;

namespace TechSupport.Account.Data;

public sealed class AccountDbContext : DbContext
{
    public AccountDbContext(DbContextOptions<AccountDbContext> options) : base(options)
    {
    }

    public DbSet<QuickSaleAccountEntry> QuickSaleAccountEntries => Set<QuickSaleAccountEntry>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("account");

        modelBuilder.Entity<QuickSaleAccountEntry>(b =>
        {
            b.ToTable("quick_sale_account_entries");
            b.HasKey(x => x.Id);
            b.Property(x => x.EntryNumber).HasMaxLength(64).IsRequired();
            b.Property(x => x.EntryType).HasConversion<string>().HasMaxLength(32).IsRequired();
            b.Property(x => x.Currency).HasMaxLength(8).IsRequired();
            b.Property(x => x.PaymentMethod).HasMaxLength(32).IsRequired();
            b.Property(x => x.Description).HasMaxLength(512).IsRequired();
            b.Property(x => x.GrossAmount).HasPrecision(18, 2);
            b.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            b.Property(x => x.NetAmount).HasPrecision(18, 2);
            b.HasIndex(x => new { x.TenantId, x.QuickSaleId });
            b.HasIndex(x => new { x.TenantId, x.EntryNumber }).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}
