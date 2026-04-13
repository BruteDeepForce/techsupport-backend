namespace TechSupport.Operation.Domain.Entities;

public sealed class TicketAttachment
{
    public Guid Id { get; set; }
    public Guid? TicketId { get; set; }
    public Ticket? Ticket { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public string Url { get; set; } = string.Empty; // object storage URL
    public long Size { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
