using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace TechSupport.Shared;

/// <summary>
/// Minimal contract for a module in the modular-monolith.
/// Each module should provide service registrations and endpoint mapping.
/// </summary>
public interface IModule
{
    IServiceCollection AddModuleServices(IServiceCollection services, IConfiguration configuration);
    IEndpointRouteBuilder MapModuleEndpoints(IEndpointRouteBuilder endpoints);
}
