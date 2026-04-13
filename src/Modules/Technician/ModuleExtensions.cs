using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Technician.Data;
using TechSupport.Technician.Services;

namespace TechSupport.Technician;

public static class ModuleExtensions
{
    public static IServiceCollection AddTechnicianModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<TechnicianDbContext>(opt =>
            opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<TechnicianDbContext>();
            dbContext.Database.Migrate();
        }

        services.AddScoped<ITechnicianService, TechnicianService>();
        services.AddSingleton<S3Service>(sp => new S3Service(configuration));
    
        return services;
    }
}
