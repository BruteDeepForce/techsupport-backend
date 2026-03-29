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

namespace TechSupport.Ai;

public static class ModuleExtensions
{
    [Obsolete("EmbeddingClient Env alınacak, Şuan sadece test amaçlı")]
    public static IServiceCollection AddAiModule(this IServiceCollection services, IConfiguration configuration)
    {
        var conn = configuration.GetConnectionString("DefaultConnection") ?? configuration["ConnectionStrings:DefaultConnection"];

        services.AddSingleton<EmbeddingClient>(sp =>
        {
            const string endpoint = "https://doksan9-rag.openai.azure.com/openai/v1/";
            string apiKey = "6TZk8IrJRC2xENHlOHvnrTgYPUJPaReDkm8qoPJpp1xor1N8HHYyJQQJ99BKACYeBjFXJ3w3AAABACOGZfHg";
            const string deploymentName = "embedding-model";

            OpenAIClient client = new(
                new ApiKeyCredential(apiKey),
                new OpenAIClientOptions()
                {
                    Endpoint = new Uri(endpoint)
                });

            return client.GetEmbeddingClient(deploymentName);
        });
        services.AddSingleton<ChatClient>(sp =>
        {
            const string endpoint = "https://doksan9-rag.openai.azure.com/openai/v1/";
            string apiKey = "6TZk8IrJRC2xENHlOHvnrTgYPUJPaReDkm8qoPJpp1xor1N8HHYyJQQJ99BKACYeBjFXJ3w3AAABACOGZfHg";
            const string deploymentName = "gpt-model"; // Replaced with a generic gpt-model deployment name

            OpenAIClient client = new(
                new ApiKeyCredential(apiKey),
                new OpenAIClientOptions()
                {
                    Endpoint = new Uri(endpoint)
                });

            return client.GetChatClient(deploymentName);
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


        return services;
    }
}
