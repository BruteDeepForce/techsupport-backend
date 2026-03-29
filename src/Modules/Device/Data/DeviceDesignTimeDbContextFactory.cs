using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Device.Data;

public sealed class DeviceDesignTimeDbContextFactory : IDesignTimeDbContextFactory<DeviceDbContext>
{
    public DeviceDbContext CreateDbContext(string[] args)
    {
        var conn =
            Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? Environment.GetEnvironmentVariable("DefaultConnection")
            ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

        var options = new DbContextOptionsBuilder<DeviceDbContext>()
            .UseNpgsql(conn)
            .Options;

        return new DeviceDbContext(options);
    }
}
