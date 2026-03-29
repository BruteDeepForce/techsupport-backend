using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.Data;

public sealed class OperationDbContext : DbContext
{
    public OperationDbContext(DbContextOptions<OperationDbContext> options) : base(options)
    {
    }

    public DbSet<OperationRecord> Operations => Set<OperationRecord>();
    public DbSet<Ticket> Tickets => Set<Ticket>();
    public DbSet<TicketAttachment> TicketAttachments => Set<TicketAttachment>();

    public DbSet<OperationProductType> ProductTypes => Set<OperationProductType>();
    public DbSet<OperationBrand> Brands => Set<OperationBrand>();
    public DbSet<OperationProductClass> Classes => Set<OperationProductClass>();
    public DbSet<MaintenanceTemplate> MaintenanceTemplates => Set<MaintenanceTemplate>();
    public DbSet<MaintenanceTemplateChecklist> MaintenanceTemplateChecklists => Set<MaintenanceTemplateChecklist>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("operations");

        modelBuilder.Entity<OperationProductType>(b =>
        {
            b.ToTable("product_types");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(128).IsRequired();
            b.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.IsActive });
        });

        modelBuilder.Entity<OperationBrand>(b =>
        {
            b.ToTable("brands");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(128).IsRequired();
            b.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.IsActive });
        });

        modelBuilder.Entity<OperationProductClass>(b =>
        {
            b.ToTable("classes");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(128).IsRequired();
            b.HasIndex(x => new { x.TenantId, x.Name }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.IsActive });
        });

        modelBuilder.Entity<MaintenanceTemplate>(b =>
        {
            b.ToTable("maintenance_templates");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(256).IsRequired();
            b.Property(x => x.Description).HasMaxLength(2000);
            b.Property(x => x.ProductTypeName).HasMaxLength(128);
            b.Property(x => x.BrandName).HasMaxLength(128);
            b.Property(x => x.ClassName).HasMaxLength(128);
            b.HasIndex(x => new { x.TenantId, x.IsActive });

            b.HasMany(x => x.Checklists)
                .WithOne(i => i.MaintenanceTemplate)
                .HasForeignKey(i => i.MaintenanceTemplateId)
                .OnDelete(DeleteBehavior.Cascade);

            b.HasOne(x => x.ProductType)
                .WithMany()
                .HasForeignKey(x => x.ProductTypeId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(x => x.Brand)
                .WithMany()
                .HasForeignKey(x => x.BrandId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(x => x.Class)
                .WithMany()
                .HasForeignKey(x => x.ClassId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<MaintenanceTemplateChecklist>(b =>
        {
            b.ToTable("maintenance_template_checklists");
            b.HasKey(x => x.Id);
            b.Property(x => x.Title).HasMaxLength(256).IsRequired();
            b.Property(x => x.Description).HasMaxLength(2000);
            b.HasIndex(x => new { x.MaintenanceTemplateId, x.SortOrder });
            b.HasOne(x => x.MaintenanceTemplate)
                .WithMany(x => x.Checklists)
                .HasForeignKey(x => x.MaintenanceTemplateId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<OperationRecord>(b =>
        {
            b.ToTable("operations");
            b.HasKey(x => x.Id);
            b.Property(x => x.Title).HasMaxLength(256).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(50).IsRequired();
            b.Property(x => x.Description).HasMaxLength(4000);
            b.Property(x => x.InternalNote).HasMaxLength(4000);
            b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(50).IsRequired();
            b.Property(x => x.Type).HasConversion<string>().HasMaxLength(50).IsRequired();

            b.HasOne(x => x.MaintenanceTemplate)
                .WithMany()
                .HasForeignKey(x => x.MaintenanceTemplateId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(x => x.Ticket)
                .WithOne(t => t.Operation)
                .HasForeignKey<OperationRecord>(o => o.TicketId)
                .OnDelete(DeleteBehavior.Cascade);
            b.HasIndex(x => new { x.TenantId, x.CreatedByUserId });
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            b.HasIndex(x => new { x.TenantId, x.DeviceId });
            b.HasIndex(x => new { x.TenantId, x.Type });
            b.HasIndex(x => x.MaintenanceTemplateId);
            b.HasIndex(x => x.FieldTechnicianUserId);
            b.HasIndex(x => x.TicketId).IsUnique();
        });
        modelBuilder.Entity<Ticket>(b =>
        {
            b.ToTable("tickets");
            b.HasKey(x => x.Id);
            b.Property(x => x.Title).HasMaxLength(256).IsRequired();
            b.Property(x => x.Description).HasMaxLength(4000);
            b.Property(x => x.Priority).HasMaxLength(50).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(50).IsRequired();
            b.HasMany(t => t.Attachments)
                .WithOne(a => a.Ticket)
                .HasForeignKey(a => a.TicketId)
                .OnDelete(DeleteBehavior.Cascade);
            b.HasIndex(x => new { x.TenantId, x.CreatedByUserId });
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            b.HasIndex(x => new { x.TenantId, x.DeviceId });
        });
        modelBuilder.Entity<TicketAttachment>(b =>
        {
            b.ToTable("ticket_attachments");
            b.HasKey(x => x.Id);
            b.Property(x => x.FileName).HasMaxLength(256).IsRequired();
            b.Property(x => x.ContentType).HasMaxLength(100).IsRequired();
            b.HasIndex(x => x.TicketId);
        });

        base.OnModelCreating(modelBuilder);
    }
}
