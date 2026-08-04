using Microsoft.EntityFrameworkCore;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Shared.Integration;

namespace TechSupport.Accounting.Data;

public class AccountingDbContext : DbContext, IIntegrationMessageDbContext
{
    public AccountingDbContext(DbContextOptions<AccountingDbContext> options) : base(options)
    {
    }

    public DbSet<Account> Accounts { get; set; }
    public DbSet<Invoice> Invoices { get; set; }
    public DbSet<InvoiceLineItem> InvoiceLineItems { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<CariHesapHareketi> CariHesapHareketleri { get; set; }
    public DbSet<IntegrationOutboxMessage> IntegrationOutboxMessages => Set<IntegrationOutboxMessage>();
    public DbSet<ProcessedIntegrationMessage> ProcessedIntegrationMessages => Set<ProcessedIntegrationMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Use dedicated Postgres schema for accounting module
        modelBuilder.HasDefaultSchema("accounting");

        // Global query filter for soft delete
        modelBuilder.Entity<Account>().HasQueryFilter(x => !x.IsDeleted);
        modelBuilder.Entity<Invoice>().HasQueryFilter(x => !x.IsDeleted);
        modelBuilder.Entity<InvoiceLineItem>().HasQueryFilter(x => !x.IsDeleted);
        modelBuilder.Entity<Payment>().HasQueryFilter(x => !x.IsDeleted);
        modelBuilder.Entity<CariHesapHareketi>().HasQueryFilter(x => !x.IsDeleted);

        // Account configuration
        modelBuilder.Entity<Account>(b =>
        {
            b.ToTable("accounts");
            b.HasKey(x => x.Id);
            b.Property(x => x.AccountNumber).HasMaxLength(50).IsRequired();
            b.Property(x => x.Name).HasMaxLength(200).IsRequired();
            b.Property(x => x.Balance).HasPrecision(18, 2);
            b.Property(x => x.TotalBorc).HasPrecision(18, 2);
            b.Property(x => x.TotalAlacak).HasPrecision(18, 2);
            b.Property(x => x.CreditLimit).HasPrecision(18, 2);
            b.Property(x => x.Type).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.CreatedBy).HasMaxLength(100);
            b.Property(x => x.UpdatedBy).HasMaxLength(100);
            
            // Concurrency token for optimistic locking
            b.Property(x => x.RowVersion).IsRowVersion();
            
            // One account per tenant (as per business requirement)
            b.HasIndex(x => x.TenantId).IsUnique();
            // Unique index: TenantId + AccountNumber (still useful if AccountNumber is kept)
            b.HasIndex(x => new { x.TenantId, x.AccountNumber }).IsUnique();
            // Index: TenantId + Type
            b.HasIndex(x => new { x.TenantId, x.Type });
            // Index: TenantId + Status
            b.HasIndex(x => new { x.TenantId, x.Status });
        });

        // Invoice configuration
        modelBuilder.Entity<Invoice>(b =>
        {
            b.ToTable("invoices");
            b.HasKey(x => x.Id);
            b.Property(x => x.InvoiceNumber).HasMaxLength(50).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Type).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Subtotal).HasPrecision(18, 2);
            b.Property(x => x.TaxAmount).HasPrecision(18, 2);
            b.Property(x => x.TotalAmount).HasPrecision(18, 2);
            b.Property(x => x.PaidAmount).HasPrecision(18, 2);
            b.Property(x => x.Notes).HasMaxLength(2000);
            b.Property(x => x.CreatedBy).HasMaxLength(100);
            b.Property(x => x.UpdatedBy).HasMaxLength(100);
            
            // Unique index: TenantId + InvoiceNumber
            b.HasIndex(x => new { x.TenantId, x.InvoiceNumber }).IsUnique();
            // Index: TenantId + AccountId
            b.HasIndex(x => new { x.TenantId, x.AccountId });
            // Index: TenantId + CustomerId
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            // Index: TenantId + Status
            b.HasIndex(x => new { x.TenantId, x.Status });
            // Index: TenantId + DueDate (for overdue calculations)
            b.HasIndex(x => new { x.TenantId, x.DueDate });
            
            // Relation: Invoice -> Account
            b.HasOne(x => x.Account)
                .WithMany(a => a.Invoices)
                .HasForeignKey(x => x.AccountId)
                .OnDelete(DeleteBehavior.Cascade);
            
            // Customer is tracked in Customer module; keep only CustomerId here (no FK relationship)
        });

        // InvoiceLineItem configuration
        modelBuilder.Entity<InvoiceLineItem>(b =>
        {
            b.ToTable("invoice_line_items");
            b.HasKey(x => x.Id);
            b.Property(x => x.Description).HasMaxLength(500).IsRequired();
            b.Property(x => x.ProductCode).HasMaxLength(100);
            b.Property(x => x.Quantity).HasPrecision(18, 4);
            b.Property(x => x.Unit).HasMaxLength(20);
            b.Property(x => x.UnitPrice).HasPrecision(18, 4);
            b.Property(x => x.TaxRate).HasPrecision(5, 4);
            b.Property(x => x.TaxAmount).HasPrecision(18, 2);
            b.Property(x => x.LineTotal).HasPrecision(18, 2);
            b.Property(x => x.CreatedBy).HasMaxLength(100);
            b.Property(x => x.UpdatedBy).HasMaxLength(100);
            
            b.HasIndex(x => new { x.InvoiceId });
            
            // Relation: InvoiceLineItem -> Invoice
            b.HasOne(x => x.Invoice)
                .WithMany(i => i.LineItems)
                .HasForeignKey(x => x.InvoiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Payment configuration
        modelBuilder.Entity<Payment>(b =>
        {
            b.ToTable("payments");
            b.HasKey(x => x.Id);
            b.Property(x => x.PaymentNumber).HasMaxLength(50).IsRequired();
            b.Property(x => x.Method).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Amount).HasPrecision(18, 2);
            b.Property(x => x.FeeAmount).HasPrecision(18, 2);
            b.Property(x => x.NetAmount).HasPrecision(18, 2);
            b.Property(x => x.ReferenceNumber).HasMaxLength(100);
            b.Property(x => x.Notes).HasMaxLength(1000);
            b.Property(x => x.CreatedBy).HasMaxLength(100);
            b.Property(x => x.UpdatedBy).HasMaxLength(100);
            
            // Unique index: TenantId + PaymentNumber
            b.HasIndex(x => new { x.TenantId, x.PaymentNumber }).IsUnique();
            // Index: TenantId + AccountId
            b.HasIndex(x => new { x.TenantId, x.AccountId });
            // Index: TenantId + CustomerId
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            // Index: TenantId + InvoiceId
            b.HasIndex(x => new { x.TenantId, x.InvoiceId });
            // Index: TenantId + Status
            b.HasIndex(x => new { x.TenantId, x.Status });
            // Index: TenantId + PaymentDate
            b.HasIndex(x => new { x.TenantId, x.PaymentDate });
            
            // Relation: Payment -> Account
            b.HasOne(x => x.Account)
                .WithMany(a => a.Payments)
                .HasForeignKey(x => x.AccountId)
                .OnDelete(DeleteBehavior.Cascade);
            
            // Relation: Payment -> Invoice (optional)
            b.HasOne(x => x.Invoice)
                .WithMany(i => i.Payments)
                .HasForeignKey(x => x.InvoiceId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // CariHesapHareketi configuration
        modelBuilder.Entity<CariHesapHareketi>(b =>
        {
            b.ToTable("cari_hesap_hareketleri");
            b.HasKey(x => x.Id);
            
            b.Property(x => x.HareketTipi).HasConversion<string>().HasMaxLength(20);
            b.Property(x => x.Borc).HasPrecision(18, 2);
            b.Property(x => x.Alacak).HasPrecision(18, 2);
            b.Property(x => x.Bakiye).HasPrecision(18, 2);
            b.Property(x => x.Aciklama).HasMaxLength(500);
            b.Property(x => x.ReferansNumarasi).HasMaxLength(100);
            b.Property(x => x.BelgeNumarasi).HasMaxLength(100);
            b.Property(x => x.CreatedBy).HasMaxLength(100);
            b.Property(x => x.UpdatedBy).HasMaxLength(100);
            
            // Index: TenantId + AccountId
            b.HasIndex(x => new { x.TenantId, x.AccountId });
            // Index: TenantId + CustomerId
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            // Index: TenantId + InvoiceId
            b.HasIndex(x => new { x.TenantId, x.InvoiceId });
            // Index: TenantId + PaymentId
            b.HasIndex(x => new { x.TenantId, x.PaymentId });
            // Index: TenantId + IslemTarihi (for date range queries)
            b.HasIndex(x => new { x.TenantId, x.IslemTarihi });
            // Composite index for account statement (ekstre) queries
            b.HasIndex(x => new { x.TenantId, x.AccountId, x.IslemTarihi });
            b.HasIndex(x => new { x.TenantId, x.ReferansNumarasi }).IsUnique()
                .HasFilter("\"ReferansNumarasi\" IS NOT NULL");
            
            // Relation: CariHesapHareketi -> Account
            b.HasOne(x => x.Account)
                .WithMany(a => a.CariHesapHareketleri)
                .HasForeignKey(x => x.AccountId)
                .OnDelete(DeleteBehavior.Cascade);
            
            // Relation: CariHesapHareketi -> Invoice (optional)
            b.HasOne(x => x.Invoice)
                .WithMany(i => i.CariHesapHareketleri)
                .HasForeignKey(x => x.InvoiceId)
                .OnDelete(DeleteBehavior.SetNull);
            
            // Relation: CariHesapHareketi -> Payment (optional)
            b.HasOne(x => x.Payment)
                .WithMany(p => p.CariHesapHareketleri)
                .HasForeignKey(x => x.PaymentId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.ConfigureIntegrationMessages();
    }
}
