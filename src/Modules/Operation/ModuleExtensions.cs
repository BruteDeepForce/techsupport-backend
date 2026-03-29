using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Operation.Data;
using TechSupport.Operation.Services;

namespace TechSupport.Operation;

public static class ModuleExtensions
{
    public static IServiceCollection AddOperationModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<OperationDbContext>(opt => opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<OperationDbContext>();
            dbContext.Database.Migrate();
        }

        services.AddScoped<IOperationService, OperationService>();
        services.AddScoped<ITicketService, TicketService>();

        return services;
    }
}
