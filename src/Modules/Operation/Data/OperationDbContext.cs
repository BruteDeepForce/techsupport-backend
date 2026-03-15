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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("operations");

        modelBuilder.Entity<OperationRecord>(b =>
        {
            b.ToTable("operations");
            b.HasKey(x => x.Id);
            b.Property(x => x.Title).HasMaxLength(256).IsRequired();
            b.Property(x => x.Status).HasConversion<string>().HasMaxLength(50).IsRequired();
            b.Property(x => x.Description).HasMaxLength(4000);
            b.Property(x => x.InternalNote).HasMaxLength(4000);
            b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(50).IsRequired();
            b.HasOne(x => x.Ticket)
                .WithOne(t => t.Operation)
                .HasForeignKey<OperationRecord>(o => o.TicketId)
                .OnDelete(DeleteBehavior.Cascade);
            b.HasIndex(x => new { x.TenantId, x.CreatedByUserId });
            b.HasIndex(x => new { x.TenantId, x.CustomerId });
            b.HasIndex(x => new { x.TenantId, x.DeviceId });
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
