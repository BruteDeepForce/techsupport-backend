using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Stock.Data;

namespace TechSupport.Stock;

public static class ModuleExtensions
{
    public static IServiceCollection AddStockModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<StockDbContext>(opt => opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<StockDbContext>();
            dbContext.Database.Migrate();
        }

    services.AddScoped<Services.IStockService, Services.StockService>();
    services.AddScoped<Services.ICategoryService, Services.CategoryService>();

        return services;
    }
}
