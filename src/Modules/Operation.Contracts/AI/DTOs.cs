using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Operation.Contracts.AI
{
    public sealed record QueryOperation(
        Guid TenantId,
        Guid BranchId,
        DateTime? From,
        DateTime? To);
    public sealed record ResponseOperation(
        Guid Id,
        Guid TenantId,
        Guid? BranchId,
        Guid CustomerId,
        Guid DeviceId,
        Guid? TechnicianUserId,
        string Title,
        string Description,
        string Status,
        string InternalNote,
        string CustomerName,
        string TechnicianName,
        string Priority,
        DateTimeOffset OccurredAtUtc,
        string Type,
        Guid? MaintenanceTemplateId,
        string Future,
        DateTimeOffset? ScheduledAtUtc);

    public sealed record ResponseTicket(
        Guid Id,
        Guid TenantId,
        Guid? BranchId,

        Guid CustomerId,
        Guid? DeviceId,

        string? CustomerName,
        Guid? OperationId,

        string Title,
        string Description,
        string Priority,

        string Status,

        Guid? CreatedByUserId,
        DateTimeOffset CreatedAtUtc,
        DateTimeOffset? UpdatedAtUtc,
        ICollection<TicketAttachment>? Attachments

    );
    public sealed record TicketAttachment(
        Guid Id,
        string FileName,
        string FileUrl,
        DateTimeOffset UploadedAtUtc
    );

    public sealed record TechnicianInformation(
        Guid TechnicianUserId,
        string TechnicianName
    );
}