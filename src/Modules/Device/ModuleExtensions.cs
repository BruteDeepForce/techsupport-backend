using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Device.Data;
using TechSupport.Device.Services;

namespace TechSupport.Device;

public static class ModuleExtensions
{
    public static IServiceCollection AddDeviceModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<DeviceDbContext>(opt => opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<DeviceDbContext>();
            dbContext.Database.Migrate();
        }
        services.AddScoped<IDeviceService, DeviceService>();

        return services;
    }
}
