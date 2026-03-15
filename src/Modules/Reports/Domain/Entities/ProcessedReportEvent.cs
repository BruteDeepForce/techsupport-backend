namespace TechSupport.Reports.Domain.Entities;

public sealed class ProcessedReportEvent
{
    public Guid Id { get; set; }
    public string EventName { get; set; } = string.Empty;
    public Guid? MessageId { get; set; }
    public Guid? CorrelationId { get; set; }
    public Guid TenantId { get; set; }
    public DateTimeOffset ProcessedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
