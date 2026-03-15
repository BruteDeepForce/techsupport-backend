using TechSupport.Customer.Contracts.Events;

namespace TechSupport.Reports.Services;

public interface ICustomerReportSetService
{
    Task HandleCustomerCreatedAsync(CustomerCreated message, CancellationToken ct);
}
