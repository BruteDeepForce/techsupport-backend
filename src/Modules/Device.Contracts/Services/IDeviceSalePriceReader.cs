namespace TechSupport.Device.Contracts.Services;

public interface IDeviceSalePriceReader
{
    Task<decimal?> GetCurrentSalePriceAsync(Guid tenantId, Guid deviceId, CancellationToken cancellationToken = default);
}
