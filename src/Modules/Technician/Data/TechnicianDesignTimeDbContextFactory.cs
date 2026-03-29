using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Technician.Data;

public sealed class TechnicianDesignTimeDbContextFactory : IDesignTimeDbContextFactory<TechnicianDbContext>
{
    public TechnicianDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<TechnicianDbContext>();
        var conn = Environment.GetEnvironmentVariable("TECHSUPPORT_CONNECTION") ??
                   "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";
        builder.UseNpgsql(conn);
        return new TechnicianDbContext(builder.Options);
    }
}
