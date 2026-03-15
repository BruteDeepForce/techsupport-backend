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

            services.AddScoped<Services.ICustomerService, Services.CustomerService>();

            return services;
        }
    }
}