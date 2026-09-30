using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using TechSupport.Ai.Data;
using TechSupport.Ai.Services;
using Ai.Services;
using OpenAI.Embeddings;
using OpenAI;
using System.ClientModel;
using OpenAI.Chat;
using Npgsql;
using Pgvector.EntityFrameworkCore;
using Microsoft.SemanticKernel;
using Ai.Services.SemanticKernel;
using Ai.Services.SemanticKernel.Tools;

namespace TechSupport.Ai;

public static class ModuleExtensions
{
    [Obsolete("EmbeddingClient Env alınacak, Şuan sadece test amaçlı")]
    public static IServiceCollection AddAiModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];
        var deploymenTName = configuration["AzureSemanticKernel:OpenAI:DeploymentName"];
        var endpoint = configuration["AzureSemanticKernel:OpenAI:Endpoint"];
        var apiKey = configuration["AzureSemanticKernel:OpenAI:ApiKey"];

        // services.AddSingleton<EmbeddingClient>(sp =>
        // {
        //     const string endpoint = "https://doksan9-rag.openai.azure.com/openai/v1/";
        //     string apiKey = configuration["AzureAI:Key"];
        //     const string deploymentName = "embedding-model";

        //     OpenAIClient client = new(
        //         new ApiKeyCredential(apiKey),
        //         new OpenAIClientOptions()
        //         {
        //             Endpoint = new Uri(endpoint)
        //         });

        //     return client.GetEmbeddingClient(deploymentName);
        // });
        // services.AddSingleton<ChatClient>(sp =>
        // {
        //     const string endpoint = "https://doksan9-rag.openai.azure.com/openai/v1/";
        //     string apiKey = configuration["AzureAI:Key"];
        //     const string deploymentName = "gpt-model"; // Replaced with a generic gpt-model deployment name

        //     OpenAIClient client = new(
        //         new ApiKeyCredential(apiKey),
        //         new OpenAIClientOptions()
        //         {
        //             Endpoint = new Uri(endpoint)
        //         });

        //     return client.GetChatClient(deploymentName);
        // });

        services.AddHttpClient();

        services.AddHttpClient("OpenAI", client =>
        {
            client.BaseAddress = new Uri(endpoint, UriKind.Absolute);
        });

        services.AddTransient<Kernel>((sp) =>
        {
            var factory = sp.GetRequiredService<IHttpClientFactory>();

            var httpClient = factory.CreateClient("OpenAI");

            return Kernel.CreateBuilder()
            .AddOpenAIChatCompletion(
                modelId: deploymenTName,
                apiKey: apiKey,
                httpClient: httpClient).Build();
        });

        services.AddDbContext<AiDbContext>(opt =>
        {
            var dataSourceBuilder = new Npgsql.NpgsqlDataSourceBuilder(conn);
            dataSourceBuilder.UseVector();
            var dataSource = dataSourceBuilder.Build();

            opt.UseNpgsql(dataSource, o => o.UseVector());
        });


        using (var scope = services.BuildServiceProvider().CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<AiDbContext>();
            dbContext.Database.Migrate();
        }

        services.AddScoped<IOperationCreated, OperationCreated>();
        services.AddScoped<IEmbeddingService, EmbeddingService>();
        services.AddScoped<IEmbeddingQueryService, EmbeddingQueryService>();
        services.AddScoped<IAIOrchestartorService, AIOrchestratorService>();
        services.AddScoped<IAIResponseFormatter, AIResponseFormatterService>();
        services.AddScoped<IOperationStatusChanged, OperationStatusChanged>();
        services.AddScoped<ISemanticKernelOrchestrator, SemanticKernelOrchestrator>();
        services.AddScoped<AiKernelRequestContext>();
        services.AddScoped<OperationActionTool>();
        services.AddScoped<TechnicianActionTool>();
        services.AddScoped<StockActionTool>();
        services.AddScoped<AccountingActionTool>();
        services.AddScoped<CustomerActionTool>();
        services.AddScoped<HrActionTool>();


        return services;
    }
}
