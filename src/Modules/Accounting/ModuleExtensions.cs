using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Accounting.Data;
using TechSupport.Accounting.Services;
using StackExchange.Redis;
using TechSupport.Accounting.RedisService;

namespace TechSupport.Accounting;

public static class ModuleExtensions
{
    public static IServiceCollection AddAccountingModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        // Register DbContext
        services.AddDbContext<AccountingDbContext>(opt => opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<AccountingDbContext>();
            dbContext.Database.Migrate();
        }

        // Register Redis
        var redisConnectionString = configuration.GetConnectionString("Redis:ConnectionString") ?? configuration["Redis:ConnectionString"];
        var redis = ConnectionMultiplexer.Connect(redisConnectionString);
        services.AddSingleton<IConnectionMultiplexer>(redis);

        // Register Services
        services.AddScoped<IAccountService, AccountService>();
        services.AddScoped<ICariHesapService, CariHesapService>();
        services.AddScoped<IInvoiceService, InvoiceService>();
        services.AddScoped<IPaymentService, PaymentService>();
        services.AddScoped<IRedisCacheService, RedisCacheService>();

        return services;
    }
}
