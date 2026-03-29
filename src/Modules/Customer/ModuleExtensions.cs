using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace TechSupport.Customer
{
    public static class ModuleExtensions
    {
        public static IServiceCollection AddCustomerModule(this IServiceCollection services, IConfiguration configuration)
        {
            var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

            services.AddDbContext<TechSupport.Customer.Data.CustomerDbContext>(opt =>
                opt.UseNpgsql(conn));

            using (var scope = services.BuildServiceProvider().CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<Data.CustomerDbContext>();
                dbContext.Database.Migrate();
            }

            services.AddScoped<Services.ICustomerService, Services.CustomerService>();

            return services;
        }
    }
}