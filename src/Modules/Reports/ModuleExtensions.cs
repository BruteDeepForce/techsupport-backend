using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Data;
using TechSupport.Reports.Services;
using Reports.Services;

namespace TechSupport.Reports;

public static class ModuleExtensions
{
    public static IServiceCollection AddReportsModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<ReportDbContext>(opt =>
            opt.UseNpgsql(conn));

        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<ReportDbContext>();
            dbContext.Database.Migrate();
        }

        services.AddScoped<ReportSetStore>();
        services.AddScoped<ICustomerReportSetService, CustomerReportSetService>();
        services.AddScoped<IOperationReportSetService, OperationReportSetService>();
        services.AddScoped<ITechnicianReportSetService, TechnicianReportSetService>();
        services.AddScoped<ITenantSetService, TenantSetService>();
        services.AddScoped<IReportService, ReportService>();
        services.AddScoped<IReportQueryService, ReportQueryService>();

        return services;
    }
}
