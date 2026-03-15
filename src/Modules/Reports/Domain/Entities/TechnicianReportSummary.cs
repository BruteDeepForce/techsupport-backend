namespace TechSupport.Reports.Domain.Entities;

/// <summary>
/// A technician dimension + high-level summary row for reporting.
///
/// Stores a snapshot of identity fields (name/email) so reports can be
/// rendered without cross-module joins.
/// </summary>
public sealed class TechnicianReportSummary
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    /// <summary>
    /// The identity/user id of the technician in the system.
    /// </summary>
    public Guid TechnicianUserId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string? PhoneNumber { get; set; }

    /// <summary>
    /// Last time we updated the snapshot based on events.
    /// </summary>
    public DateTimeOffset? LastProfileUpdateAtUtc { get; set; }

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
