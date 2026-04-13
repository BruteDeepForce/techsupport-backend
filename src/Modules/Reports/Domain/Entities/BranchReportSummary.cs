namespace TechSupport.Reports.Domain.Entities;

public sealed class BranchReportSummary
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public int TotalCustomers { get; set; }
    public int TotalOperations { get; set; }
    public int CompletedOperations { get; set; }
    public int FailedOperations { get; set; }
    public int DeliveredOperations { get; set; }
    public int OpenOperations { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
