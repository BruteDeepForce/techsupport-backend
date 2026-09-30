namespace TechSupport.Customer.Contracts.AI;

/// <summary>
/// AI tarafına müşteri kartı bilgisini taşır.
/// </summary>
public sealed record CustomerInfoResponse(
    Guid CustomerId,
    string Name,
    string? Email,
    string? PhoneNumber,
    int DeviceCount);

/// <summary>
/// AI tarafına müşteriye bağlı cihaz bilgisini taşır.
/// </summary>
public sealed record CustomerDeviceInfoResponse(
    Guid DeviceId,
    Guid CustomerId,
    string? CustomerName,
    string? Brand,
    string? Model,
    string? SerialNumber,
    string? BarcodeNumber,
    string? ProblemDescription,
    string? Status,
    bool IsActive,
    int? GuaranteePeriod,
    DateTimeOffset? WarrantyEndAtUtc);

/// <summary>
/// AI tarafına tenant/branch seviyesinde müşteri özetini taşır.
/// </summary>
public sealed record CustomerSummaryResponse(
    int TotalCustomerCount,
    int TotalDeviceCount,
    int ActiveDeviceCount,
    int ExpiredWarrantyCount,
    int ProblemDeviceCount);