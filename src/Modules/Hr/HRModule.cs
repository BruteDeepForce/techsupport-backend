using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Modules.HR.Application;
using Modules.HR.Infrastructure;
using TechSupport.Hr.Application;
using TechSupport.Hr.SignalR;

namespace TechSupport.Hr
{

public static class HRModule
{
    public static IServiceCollection AddHRModule(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<HRDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IEmployeeService, EmployeeService>();
        services.AddScoped<IDepartmentService, DepartmentService>();
        services.AddScoped<IPositionService, PositionService>();
        services.AddScoped<IShiftTemplateService, ShiftTemplateService>();
        services.AddScoped<IShiftAssignmentService, ShiftAssignmentService>();
        services.AddScoped<IAttendanceService, AttendanceService>();
        services.AddScoped<IAdvanceService, AdvanceService>();
        services.AddScoped<ILeaveService, LeaveService>();
        services.AddScoped<ILeaveSettingsService, LeaveSettingsService>();
        services.AddScoped<IMiniReportService, MiniReportService>();
        services.AddScoped<IBordroService, BordroService>();
        services.AddScoped<IEmployeeSalaryService, EmployeeSalaryService>();
        services.AddScoped<IDisciplineService, DisciplineService>();
        services.AddScoped<IRewardService, RewardService>();
        services.AddScoped<IEmployeeSyncService, EmployeeSyncService>();
        services.AddScoped<IEmployeePerformanceService, EmployeePerformanceService>();
        services.AddScoped<IHRNotificationHub, ShiftStatusNotifier>();

        return services;
    }
}
}
