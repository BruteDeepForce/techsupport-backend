using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Trade.Data;
using TechSupport.Trade.Services;

namespace TechSupport.Trade;

public static class ModuleExtensions
{
    public static IServiceCollection AddTradeModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];
        services.AddDbContext<TradeDbContext>(opt => opt.UseNpgsql(conn));
        services.AddScoped<IQuickSaleService, QuickSaleService>();
        return services;
    }
}
