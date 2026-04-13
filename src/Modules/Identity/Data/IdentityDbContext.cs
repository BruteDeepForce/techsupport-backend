using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace TechSupport.Identity.Data;

public class AppUser : Microsoft.AspNetCore.Identity.IdentityUser<Guid>
{
}

public class AppRole : Microsoft.AspNetCore.Identity.IdentityRole<Guid>
{
}


public class IdentityDbContext : IdentityDbContext<AppUser, AppRole, Guid>
{
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options) : base(options)
    {
    }

    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<Branch> Branches => Set<Branch>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        // Put identity tables under the 'identity' schema
        builder.HasDefaultSchema("identity");

        builder.Entity<Tenant>(b =>
        {
            b.ToTable("tenants");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(200).IsRequired();
        });

        builder.Entity<Branch>(b =>
        {
            b.ToTable("branches");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(200).IsRequired();
            b.HasOne(x => x.Tenant)
                .WithMany(x => x.Branches)
                .HasForeignKey(x => x.TenantId);
        });

        base.OnModelCreating(builder);
    }
}
