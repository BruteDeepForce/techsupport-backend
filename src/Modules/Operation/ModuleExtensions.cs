using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TechSupport.Operation.AI;
using TechSupport.Operation.Contracts.AI;
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
        services.AddScoped<IOperationPlanService, OperationPlanService>();
        services.AddScoped<ITicketService, TicketService>();
        services.AddScoped<IOfferService, OfferService>();
        services.AddScoped<IOperationQueryToAI, OperationQueryToAI>();
        services.AddScoped<ISetActionFromAI, SetActionFromAI>();
        

        return services;
    }
}
