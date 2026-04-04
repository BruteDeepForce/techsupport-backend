using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Stock.Data
{
    public class StockDesignTimeDbContextFactory : IDesignTimeDbContextFactory<StockDbContext>
    {
        public StockDbContext CreateDbContext(string[] args)
        {
            var conn =
                Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
                ?? Environment.GetEnvironmentVariable("DefaultConnection")
                ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

            var options = new DbContextOptionsBuilder<StockDbContext>()
                .UseNpgsql(conn)
                .Options;

            return new StockDbContext(options);
        }
    }
}
