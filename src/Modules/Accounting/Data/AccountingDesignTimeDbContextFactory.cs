using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace TechSupport.Accounting.Data
{
    public class AccountingDesignTimeDbContextFactory : IDesignTimeDbContextFactory<AccountingDbContext>
    {
        public AccountingDbContext CreateDbContext(string[] args)
        {
            var conn =
                Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
                ?? Environment.GetEnvironmentVariable("DefaultConnection")
                ?? "Host=localhost;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword";

            var options = new DbContextOptionsBuilder<AccountingDbContext>()
                .UseNpgsql(conn)
                .Options;

            return new AccountingDbContext(options);
        }
    }
}