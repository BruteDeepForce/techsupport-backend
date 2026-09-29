namespace TechSupport.Reports.Contracts;

public sealed record TenantReportSummaryDelta(
    int TotalCustomers = 0,
    int TotalOperations = 0,
    int CompletedOperations = 0,
    int FailedOperations = 0,
    int DeliveredOperations = 0,
    int OpenOperations = 0
);
