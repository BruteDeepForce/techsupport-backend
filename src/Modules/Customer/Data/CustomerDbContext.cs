using Microsoft.EntityFrameworkCore;
using TechSupport.Customer.Domain.Entities;

namespace TechSupport.Customer.Data
{
    public class CustomerDbContext : DbContext
    {
        public CustomerDbContext(DbContextOptions<CustomerDbContext> options) : base(options)
        {
        }

        public DbSet<TechSupport.Customer.Domain.Entities.Customer> Customers => Set<TechSupport.Customer.Domain.Entities.Customer>();
        public DbSet<TechSupport.Customer.Domain.Entities.CustomerDevice> CustomerDevices => Set<TechSupport.Customer.Domain.Entities.CustomerDevice>();
    public DbSet<CustomerProvisionRequest> CustomerProvisionRequests => Set<CustomerProvisionRequest>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("customers");

            modelBuilder.Entity<TechSupport.Customer.Domain.Entities.Customer>(b =>
            {
                b.ToTable("customers");
                b.HasKey(x => x.Id);
                b.Property(x => x.AppUserId).IsRequired(false);
                b.Property(x => x.Name).HasMaxLength(200).IsRequired();
                b.Property(x => x.Email).HasMaxLength(320).IsRequired();
                b.Property(x => x.PhoneNumber).HasMaxLength(32);
                b.HasIndex(x => new { x.TenantId, x.Email }).IsUnique();
                b.HasIndex(x => x.AppUserId).IsUnique();
                b.HasMany(x => x.Devices).WithOne(d => d.Customer).HasForeignKey(d => d.CustomerId).OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<CustomerDevice>(b =>
            {
                b.ToTable("customer_devices");
                b.HasKey(x => x.Id);
                b.Property(x => x.DeviceId).IsRequired();
                b.Property(x => x.BranchId).IsRequired(false);
                b.Property(x => x.Brand).HasMaxLength(128);
                b.Property(x => x.Model).HasMaxLength(128);
                b.Property(x => x.SerialNumber).HasMaxLength(128);
                b.Property(x => x.BarcodeNumber).HasMaxLength(128);
                b.Property(x => x.ProblemDescription).HasMaxLength(4000);
                b.Property(x => x.Status).HasMaxLength(64);
                b.HasIndex(x => new { x.CustomerId, x.DeviceId }).IsUnique();
            });

            modelBuilder.Entity<CustomerProvisionRequest>(b =>
            {
                b.ToTable("customer_provision_requests");
                b.HasKey(x => x.Id);
                b.Property(x => x.Name).HasMaxLength(200).IsRequired();
                b.Property(x => x.Email).HasMaxLength(320).IsRequired();
                b.Property(x => x.PhoneNumber).HasMaxLength(32);
                b.Property(x => x.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
                b.Property(x => x.FailureReason).HasMaxLength(1000);
                b.HasIndex(x => x.CorrelationId).IsUnique();
                b.HasIndex(x => new { x.TenantId, x.Email });
            });

            base.OnModelCreating(modelBuilder);
        }
    }
}
