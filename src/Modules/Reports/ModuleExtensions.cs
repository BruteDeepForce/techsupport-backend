using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Data;
using TechSupport.Reports.Services;

namespace TechSupport.Reports;

public static class ModuleExtensions
{
    public static IServiceCollection AddReportsModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddDbContext<ReportDbContext>(opt =>
            opt.UseNpgsql(conn));

        services.AddScoped<IReportService, ReportService>();

        return services;
    }
}
