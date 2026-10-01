using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Operation.Contracts.OutRequest;

namespace Reports.Services
{
    public interface IGetAnyReportService
    {
        Task<IReadOnlyCollection<ResponseOperationDTO>> GetOperationsAsync(Guid tenantId, CancellationToken cancellationToken);
        Task<IReadOnlyCollection<ResponseTicketDTO>> GetTicketsAsync(Guid tenantId, CancellationToken cancellationToken);
    }
    public class GetAnyReportService
    {
        private readonly IOperationRequest _operationRequest;

        public GetAnyReportService(IOperationRequest operationRequest)
        {
            _operationRequest = operationRequest;
        }

        public async Task<IReadOnlyCollection<ResponseOperationDTO>> GetOperationsAsync(Guid tenantId, CancellationToken cancellationToken)
        {
            var response = await _operationRequest.GetOperationsAsync(tenantId, cancellationToken);
            return response.Select(x => new ResponseOperationDTO(
                x.Id,
                x.TenantId,
                x.BranchId,
                x.CustomerId,
                x.DeviceId,
                x.TechnicianUserId,
                x.Title,
                x.Description,
                x.Status,
                x.InternalNote,
                x.CustomerName,
                x.TechnicianName,
                x.Priority,
                x.OccurredAtUtc,
                x.Type,
                x.MaintenanceTemplateId,
                x.Future,
                x.ScheduledAtUtc
            )).ToList();
        }


        public async Task<IReadOnlyCollection<ResponseTicketDTO>> GetTicketsAsync(Guid tenantId, CancellationToken cancellationToken)
        {
            var response = await _operationRequest.GetTicketsAsync(tenantId, cancellationToken);
            return response.Select(x => new ResponseTicketDTO(
                x.Id,
                x.TenantId,
                x.BranchId,
                x.CustomerId,
                x.DeviceId,
                x.CustomerName,
                x.OperationId,
                x.Title,
                x.Description,
                x.Priority,
                x.Status,
                x.CreatedByUserId,
                x.CreatedAtUtc,
                x.UpdatedAtUtc,
                x.Attachments?.Select(a => new TicketAttachmentDTO(
                    a.Id,
                    a.FileName,
                    a.FileUrl,
                    a.UploadedAtUtc
                )).ToList()
            )).ToList();
        }

    }
    public sealed record ResponseOperationDTO(
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

    public sealed record ResponseTicketDTO(
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
ICollection<TicketAttachmentDTO>? Attachments

);
    public sealed record TicketAttachmentDTO(
        Guid Id,
        string FileName,
        string FileUrl,
        DateTimeOffset UploadedAtUtc
    );
}