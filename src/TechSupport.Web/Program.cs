using MassTransit;
using TechSupport.Device;
using TechSupport.Customer;
using TechSupport.Stock;
using TechSupport.Customer.Consumers;
using TechSupport.Operation;
using TechSupport.Identity;
using TechSupport.Identity.Consumers;
using TechSupport.Technician.Consumers;
using TechSupport.User;
using TechSupport.Reports;
using TechSupport.Ai;
using TechSupport.Technician;
using TechSupport.Reports.Consumers;
using TechSupport.Operation.Consumers;
using Reports.Consumers;
using TechSupport.Accounting;
using TechSupport.Accounting.Consumers;
using TechSupport.Hr;
using TechSupport.Trade;
using TechSupport.Trade.Consumers;
using TechSupport.Trade.SignalR;
using TechSupport.Device.Consumers;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
.AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register AI module (pgvector mapping + AiDbContext) before MassTransit builds consumers
// to avoid EF model finalization issues around Pgvector.Vector.
builder.Services.AddAiModule(builder.Configuration);

builder.Services.AddIdentityModule(builder.Configuration);
builder.Services.AddDeviceModule(builder.Configuration);
builder.Services.AddUserModule(builder.Configuration);
builder.Services.AddCustomerModule(builder.Configuration);
builder.Services.AddOperationModule(builder.Configuration);
builder.Services.AddReportsModule(builder.Configuration);
builder.Services.AddTechnicianModule(builder.Configuration);
builder.Services.AddStockModule(builder.Configuration);
builder.Services.AddAccountingModule(builder.Configuration);
builder.Services.AddHRModule(builder.Configuration);
builder.Services.AddTradeModule(builder.Configuration);
builder.Services.AddSignalR();
//! development CORS policy - to be restricted in production
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// MassTransit + RabbitMQ configuration
builder.Services.AddMassTransit(x =>
{
    //retry policy uygulanacak
    x.AddConsumer<CustomerAccountProvisionRequestedConsumer>();
    x.AddConsumer<CustomerAccountProvisionedConsumer>();
    x.AddConsumer<CustomerAccountProvisionFailedConsumer>();
    x.AddConsumer<TradeProvisionRequestConsumer>();
    x.AddConsumer<TechnicianAccountProvisionRequestedConsumer>();
    x.AddConsumer<TechSupport.Reports.Consumers.CustomerCreatedConsumer>();
    x.AddConsumer<TechSupport.Technician.Consumers.OperationAssignedToTechnicianConsumer>();
    x.AddConsumer<TechSupport.Reports.Consumers.OperationCreatedConsumer>();
    x.AddConsumer<OperationStatusChangedConsumer>();
    x.AddConsumer<TechSupport.Reports.Consumers.TechnicianAccountProvisionedConsumer>();
    x.AddConsumer<TechSupport.Technician.Consumers.TechnicianAccountProvisionedConsumer>();
    x.AddConsumer<TechnicianAccountProvisionFailedConsumer>();
    x.AddConsumer<TechnicianOperationStatusChangedConsumer>();
    x.AddConsumer<TenantCreatedConsumer>();
    x.AddConsumer<TechSupport.Ai.Consumer.OperationCreatedConsumer>();
    x.AddConsumer<TechSupport.Ai.Consumer.UpdateOperationStatusConsumer>();
    x.AddConsumer<TechSupport.Customer.Consumers.DeviceCustomerMappingConsumer>();
    x.AddConsumer<TechSupport.Operation.Consumers.StockReservedConsumer>();
    x.AddConsumer<OfferAdminApprovedForInvoicingConsumer>();
    x.AddConsumer<TradeAccountInsertConsumer>();
    x.AddConsumer<CustomerDeviceMapCompletedConsumer>();
    x.AddConsumer<TradeAccountingProcessResultedConsumer>();
    x.AddConsumer<CustomerCreateCompleted>();
    x.AddConsumer<TradeDeviceRegistrationRequestedConsumer>();
    x.AddConsumer<TradeDeviceCreatedEventWithoutMapping>();
    x.AddConsumer<TradeDeviceUpdateRequestConsumer>();

    x.UsingRabbitMq((ctx, cfg) =>
    {
        var rabbitHost = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        cfg.Host(rabbitHost, h => { });
        cfg.ConfigureEndpoints(ctx);
    });
});





var app = builder.Build();

app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});

app.UseSwagger();
app.UseSwaggerUI();


app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<TradeStatusHub>("/trade-status-hub"); //! şuan için modular monolith ihlal edildi.

app.MapGet("/", () => Results.Ok(new { service = "TechSupport Modular Monolith", version = "0.1" }));

app.Run();
