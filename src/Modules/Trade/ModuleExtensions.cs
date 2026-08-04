using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Trade.Data;
using TechSupport.Trade.Services;
using TechSupport.Trade.SignalR;
using TechSupport.Shared.Integration;

namespace TechSupport.Trade;

public static class ModuleExtensions
{
    public static IServiceCollection AddTradeModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<TradeDbContext>(opt => opt.UseNpgsql(conn));
        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            scope.ServiceProvider.GetRequiredService<TradeDbContext>().Database.Migrate();
        }
        services.AddScoped<ITradeService, TradeService>();
        services.AddScoped<IQuickSaleService, QuickSaleService>();
        services.AddScoped<ITradeStatusHub, TradeStatusNotifier>();
        services.AddHostedService<IntegrationOutboxDispatcher<TradeDbContext>>();

        return services;
    }
}
