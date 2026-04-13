using Microsoft.EntityFrameworkCore;
using TechSupport.User.Domain.Entities;

namespace TechSupport.User.Data;

public class UserDbContext : DbContext
{
    public UserDbContext(DbContextOptions<UserDbContext> options) : base(options)
    {
    }

    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("users");

        modelBuilder.Entity<UserProfile>(b =>
        {
            b.ToTable("profiles");
            b.HasKey(x => x.Id);
            b.Property(x => x.AppUserId).IsRequired();
            b.Property(x => x.Email).HasMaxLength(320).IsRequired();
            b.Property(x => x.Role).HasMaxLength(64).IsRequired();
            b.HasIndex(x => new { x.TenantId, x.Email }).IsUnique();
            b.HasIndex(x => x.AppUserId).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}
