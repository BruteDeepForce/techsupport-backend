using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Pgvector.EntityFrameworkCore;

namespace TechSupport.Ai.Data;

public sealed class AiDesignTimeDbContextFactory : IDesignTimeDbContextFactory<AiDbContext>
{
    public AiDbContext CreateDbContext(string[] args)
    {
        // Prefer environment-provided connection string (matches ASP.NET Core convention)
        // ConnectionStrings__DefaultConnection=...
        var conn =
            Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? Environment.GetEnvironmentVariable("DefaultConnection")
            ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

        var options = new DbContextOptionsBuilder<AiDbContext>()
            .UseNpgsql(conn, o => o.UseVector())
            .Options;

        return new AiDbContext(options);
    }
}
