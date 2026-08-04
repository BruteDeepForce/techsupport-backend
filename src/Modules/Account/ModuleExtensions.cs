using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Account.Data;
using TechSupport.Account.Services;

namespace TechSupport.Account;

public static class ModuleExtensions
{
    public static IServiceCollection AddAccountModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];
        services.AddDbContext<AccountDbContext>(opt => opt.UseNpgsql(conn));
        services.AddScoped<IAccountService, AccountService>();
        return services;
    }
}
