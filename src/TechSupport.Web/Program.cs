using MassTransit;
using TechSupport.Device;
using TechSupport.Customer;
using TechSupport.Customer.Consumers;
using TechSupport.Operation;
using TechSupport.Identity;
using TechSupport.Identity.Consumers;
using TechSupport.Technician.Consumers;
using TechSupport.User;
using TechSupport.Reports;
using TechSupport.Technician;
using TechSupport.Reports.Consumers;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
.AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// MassTransit + RabbitMQ configuration
builder.Services.AddMassTransit(x =>
{
    //retry policy uygulanacak
    x.AddConsumer<CustomerAccountProvisionRequestedConsumer>();
    x.AddConsumer<CustomerAccountProvisionedConsumer>();
    x.AddConsumer<CustomerAccountProvisionFailedConsumer>();
    x.AddConsumer<TechnicianAccountProvisionRequestedConsumer>();
    // Register both consumers that handle the same CustomerCreated event
    x.AddConsumer<TechSupport.Reports.Consumers.CustomerCreatedConsumer>();
    x.AddConsumer<TechSupport.Technician.Consumers.OperationCreatedConsumer>();
    x.AddConsumer<TechnicianAccountProvisionedConsumer>();
    x.AddConsumer<TechnicianAccountProvisionFailedConsumer>();

    x.UsingRabbitMq((ctx, cfg) =>
    {
        var rabbitHost = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        cfg.Host(rabbitHost, h => { });
        cfg.ConfigureEndpoints(ctx);
    });
});

builder.Services.AddIdentityModule(builder.Configuration);
builder.Services.AddDeviceModule(builder.Configuration);
builder.Services.AddUserModule(builder.Configuration);
builder.Services.AddCustomerModule(builder.Configuration);
builder.Services.AddOperationModule(builder.Configuration);
builder.Services.AddReportsModule(builder.Configuration);
builder.Services.AddTechnicianModule(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapGet("/", () => Results.Ok(new { service = "TechSupport Modular Monolith", version = "0.1" }));

app.Run();
