using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public interface IInvoicePdfService
{
    byte[] Generate(Invoice invoice);
}
