using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Reports.Contracts;

namespace TechSupport.Operation.Services
{
    public interface IOperationPlanService
    {
        Task<bool> WritePlannedOperationSnapshotAsync(Guid tenantId, Guid? branchId, Guid planId, DateTimeOffset plannedAtUtc,
        Guid toTechnicianUserId, string technicianFullName, Guid? customerId, string customerName, string title, string description, Guid operationRecordId, CancellationToken cancellationToken);
        Task<IReadOnlyList<PlannedOperation>> GetPlannedOperationsAsync(Guid tenantId, Guid? branchId, int page, int pageSize, CancellationToken cancellationToken);
    }
    public class OperationPlanService : IOperationPlanService
    {
        private readonly ITenantReportWriter _tenantReportWriter;
        private readonly OperationDbContext _dbContext;

        public OperationPlanService(ITenantReportWriter tenantReportWriter, OperationDbContext dbContext)
        {
            _tenantReportWriter = tenantReportWriter;
            _dbContext = dbContext;
        }

        public async Task<bool> WritePlannedOperationSnapshotAsync(Guid tenantId, Guid? branchId, Guid planId, DateTimeOffset plannedAtUtc, Guid toTechnicianUserId, string technicianFullName, Guid? customerId, string customerName, string title, string description, Guid operationRecordId, CancellationToken cancellationToken)
        {
            var plannedOperation = new PlannedOperationSnapshot
            {
                Id = planId,
                TenantId = tenantId,
                BranchId = branchId,
                ScheduledAtUtc = plannedAtUtc,
                ToTechnicianUserId = toTechnicianUserId,
                TechnicianFullName = technicianFullName,
                CustomerId = customerId,
                CustomerName = customerName,
                Title = title,
                Description = description,
                OperationId = operationRecordId
            };
            var isReportWritten = await _tenantReportWriter.WritePlannedOperationAsync(plannedOperation, cancellationToken);

            if (!isReportWritten)
            {
                return false;
            }
            return true;

        }
        public async Task<IReadOnlyList<PlannedOperation>> GetPlannedOperationsAsync(Guid tenantId, Guid? branchId, int page, int pageSize, CancellationToken cancellationToken)
        {
            return await _dbContext.PlannedOperations
                .Where(po => po.TenantId == tenantId && (!branchId.HasValue || po.BranchId == branchId))
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);
        }

    }
}
