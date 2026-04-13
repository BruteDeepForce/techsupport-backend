using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Customer.Data;

public sealed class CustomerDesignTimeDbContextFactory : IDesignTimeDbContextFactory<CustomerDbContext>
{
    public CustomerDbContext CreateDbContext(string[] args)
    {
        var conn =
            Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? Environment.GetEnvironmentVariable("DefaultConnection")
            ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

        var options = new DbContextOptionsBuilder<CustomerDbContext>()
            .UseNpgsql(conn)
            .Options;

        return new CustomerDbContext(options);
    }
}
