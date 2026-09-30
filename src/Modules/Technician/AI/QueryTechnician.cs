using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Technician.Contracts.AI;
using TechSupport.Technician.DTO;
using TechSupport.Technician.Services;

namespace TechSupport.Technician.AI
{
    public class QueryTechnician : IQueryTechnician
    {
        private readonly ITechnicianService _technicianService;

        public QueryTechnician(ITechnicianService technicianService)
        {
            _technicianService = technicianService;
        }
        public async Task<IReadOnlyCollection<TechnicianInfoResponse>> QueryTechniciansAsync(Guid tenantId, Guid? branchId, CancellationToken ct)
        {
            var technicians = await _technicianService.ListAsync(tenantId, ct, branchId);
            var response = technicians.Select(t => new TechnicianInfoResponse(
                    t.Name,
                    string.IsNullOrWhiteSpace(t.Email) ? null : t.Email,
                    string.IsNullOrWhiteSpace(t.PhoneNumber) ? null : t.PhoneNumber,
                    string.IsNullOrWhiteSpace(t.PictureUrl) ? null : t.PictureUrl,
                    t.IsActive ? "Aktif" : "Pasif",
                    t.Specializations.Where(s => !string.IsNullOrWhiteSpace(s)).ToList(),
                    t.EmploymentStartDate,
                    t.AssignedOperationCount,
                    t.CompletedOperationCount,
                    t.PendingOperationCount))
                .ToList();
            return response;
        }
        public async Task<TechnicianDetailInfoResponse?> QueryTechnicianDetailAsync(Guid tenantId, Guid? branchId, string? technicianName, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(technicianName))
                return null;

            var normalizedName = technicianName.Trim();
            var technicians = await _technicianService.ListAsync(tenantId, ct, branchId);

            var match = technicians.FirstOrDefault(t =>
                            string.Equals(t.Name?.Trim(), normalizedName, StringComparison.OrdinalIgnoreCase))
                        ?? technicians.FirstOrDefault(t =>
                            t.Name != null && t.Name.Trim().StartsWith(normalizedName, StringComparison.OrdinalIgnoreCase))
                        ?? technicians.FirstOrDefault(t =>
                            t.Name != null && t.Name.Trim().Contains(normalizedName, StringComparison.OrdinalIgnoreCase));

            if (match is null)
                return null;

            var detail = await _technicianService.GetDetailAsync(tenantId, match.UserId, ct);
            if (detail is null)
                return null;

            return new TechnicianDetailInfoResponse(
                detail.Name,
                string.IsNullOrWhiteSpace(detail.Email) ? null : detail.Email,
                string.IsNullOrWhiteSpace(detail.PhoneNumber) ? null : detail.PhoneNumber,
                string.IsNullOrWhiteSpace(detail.PictureUrl) ? null : detail.PictureUrl,
                detail.StatusLabel,
                detail.Specializations.Where(s => !string.IsNullOrWhiteSpace(s)).ToList(),
                detail.EmploymentStartDate,
                detail.EmploymentMonths,
                detail.AssignedOperationCount,
                detail.CompletedOperationCount,
                detail.PendingOperationCount,
                detail.OngoingOperationCount,
                detail.CompletionRate,
                detail.RecentOperations
                    .Select(o => new TechnicianOperationSummaryInfoResponse(
                        o.Title,
                        string.IsNullOrWhiteSpace(o.OperationType) ? null : o.OperationType,
                        o.Status,
                        o.StatusLabel,
                        o.AssignedAtUtc))
                    .ToList());
        }
    }
}