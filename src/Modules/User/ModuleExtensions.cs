using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace TechSupport.User;

public static class ModuleExtensions
{
    public static IServiceCollection AddUserModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<TechSupport.User.Data.UserDbContext>(opt =>
            opt.UseNpgsql(conn));

        services.AddScoped<Services.IUserService, Services.UserService>();

        return services;
    }
}
