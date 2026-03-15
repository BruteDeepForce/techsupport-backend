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
        services.AddScoped<IDeviceService, DeviceService>();

        return services;
    }
}
