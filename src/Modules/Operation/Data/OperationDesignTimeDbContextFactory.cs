using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Operation.Data
{
    public class OperationDesignTimeDbContextFactory : IDesignTimeDbContextFactory<OperationDbContext>
    {
        public OperationDbContext CreateDbContext(string[] args)
        {
            var conn =
                Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
                ?? Environment.GetEnvironmentVariable("DefaultConnection")
                ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

            var options = new DbContextOptionsBuilder<OperationDbContext>()
                .UseNpgsql(conn)
                .Options;

            return new OperationDbContext(options);
        }
    }
}
