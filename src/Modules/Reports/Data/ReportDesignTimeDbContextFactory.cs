using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Reports.Data;

public sealed class ReportDesignTimeDbContextFactory : IDesignTimeDbContextFactory<ReportDbContext>
{
    public ReportDbContext CreateDbContext(string[] args)
    {
        var connectionString =
            Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? Environment.GetEnvironmentVariable("DefaultConnection")
            ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

        var options = new DbContextOptionsBuilder<ReportDbContext>()
            .UseNpgsql(connectionString)
            .Options;

        return new ReportDbContext(options);
    }
}
