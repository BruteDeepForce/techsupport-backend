using Microsoft.EntityFrameworkCore;
using Reports.Services;
using TechSupport.Customer.Contracts.Events;
using TechSupport.Identity.Contracts.Events;
using TechSupport.Operation.Contracts.Events;
using TechSupport.Technician.Contracts.Events;

namespace TechSupport.Reports.Services;

public sealed class ReportService : IReportService
{
    private readonly ReportSetStore _store;
    private readonly ICustomerReportSetService _customerSet;
    private readonly IOperationReportSetService _operationSet;
    private readonly ITechnicianReportSetService _technicianSet;
    private readonly ITenantSetService _tenantSet;

    public ReportService(
        ReportSetStore store,
        ICustomerReportSetService customerSet,
        IOperationReportSetService operationSet,
        ITechnicianReportSetService technicianSet,
        ITenantSetService tenantSet)
    {
        _store = store;
        _customerSet = customerSet;
        _operationSet = operationSet;
        _technicianSet = technicianSet;
        _tenantSet = tenantSet;
    }

    public async Task HandleCustomerCreatedAsync(CustomerCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(nameof(CustomerCreated), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await _customerSet.HandleCustomerCreatedAsync(message, ct);

        await tx.CommitAsync(ct);
    }
        //! OperationCreated event'ı rapor modülünde ilgili tenantın operasyon count oluşturmak için kullanılıyor.
    public async Task HandleOperationCreatedAsync(OperationCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(nameof(OperationCreated), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }
        //! burası vital dikkat et
        if(message.FieldTechnicianUserId.HasValue)
        {
            await _operationSet.HandleOperationCreatedAsync (message, ct);

            await _technicianSet.HandleOperationAssignedToTechnicianAsync(message.TenantId, message.BranchId, 
            message.FieldTechnicianUserId ?? Guid.Empty, message.OperationId, message.Description, message.OccurredAtUtc, ct);
        }
        else
        {
            await _operationSet.HandleOperationCreatedAsync(message, ct);
        }

        await tx.CommitAsync(ct);
    }
    public async Task HandleTenantCreatedAsync(TenantCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(nameof(TenantCreated), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await _tenantSet.HandleTenantCreatedAsync(message, ct);

        await tx.CommitAsync(ct);
    }

    //!! DEPRECATED METOT, OPERATION CREATED EVENT'I İLE BİRLEŞTİRİLDİ. TEKNİSYEN RAPOR SETİNDEKİ OPERATION ASSIGNED TO TECHNICIAN HANDLER'INA TAŞINDI.
    public async Task HandleOperationAssignedToTechnicianAsync(OperationCreated message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(nameof(OperationCreated), messageId, correlationId, message.TenantId, ct)) //!corelationid nerden ???
        {
            await tx.RollbackAsync(ct);
            return;
        }

        //await _technicianSet.HandleOperationAssignedToTechnicianAsync(message.TenantId, message.BranchId, message.FieldTechnicianUserId ?? Guid.Empty, message.Description, message.OccurredAtUtc, ct);

        await tx.CommitAsync(ct);
    }

    public async Task HandleTechnicianAccountProvisionedAsync(TechnicianAccountProvisioned message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        //! teknisyen oluşturma eventi ile teknisyen rapor setine yeni teknisyen ekleme işlemi yapıyoruz. 
        //! Bu sayede teknisyen oluşturulma metriklerini tutabileceğiz. 
        //! Diğer bir alternatif olarak teknisyen oluşturulma metriklerini sadece rapor setinde değil,
        //!  direkt olarak teknisyen tablosunda da tutabiliriz. Bu yaklaşım rapor seti sorgularını basitleştirir ve performansı artırır,
        //!  ancak veri modelimizi genişletir ve bazı durumlarda veri tutarsızlığına yol açabilir. 
        //! Şimdilik rapor setine ekleyerek ilerleyelim, ileride ihtiyaçlara göre değerlendirebiliriz.
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(nameof(TechnicianAccountProvisioned), messageId, correlationId, message.TenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await _store.UpsertTechnicianSummaryAsync(
            message.TenantId,
            message.BranchId,
            message.AppUserId,
            message.Name,
            message.Email,
            message.PhoneNumber,
            message.OccurredAtUtc,
            ct);

        await tx.CommitAsync(ct);
    }

    public Task HandleOperationStatusChangedAsync(OperationStatusChanged message, Guid? messageId, Guid? correlationId, CancellationToken ct)
    {
        // Only count terminal transitions. Non-terminal changes can be added later if needed.
        var newStatus = message.NewStatus;
        if (string.Equals(newStatus, "Completed", StringComparison.OrdinalIgnoreCase))
        {
            return IncrementOperationCompletedAsync(message.TenantId, message.BranchId, message.OccurredAtUtc, messageId, correlationId, ct);
        }

        if (string.Equals(newStatus, "Delivered", StringComparison.OrdinalIgnoreCase))
        {
            return IncrementOperationDeliveredAsync(message.TenantId, message.BranchId, message.OccurredAtUtc, messageId, correlationId, ct);
        }

        if (string.Equals(newStatus, "Failed", StringComparison.OrdinalIgnoreCase))
        {
            return IncrementOperationFailedAsync(message.TenantId, message.BranchId, message.OccurredAtUtc, messageId, correlationId, ct);
        }

        return Task.CompletedTask;
    }

    public Task IncrementOperationCompletedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationCompletedAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId,
            () => _operationSet.IncrementOperationCompletedAsync(tenantId, branchId, occurredAtUtc, ct), ct);

    public Task IncrementOperationDeliveredAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationDeliveredAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId,
            () => _operationSet.IncrementOperationDeliveredAsync(tenantId, branchId, occurredAtUtc, ct), ct);

    public Task IncrementOperationFailedAsync(Guid tenantId, Guid? branchId, DateTimeOffset occurredAtUtc, Guid? messageId, Guid? correlationId, CancellationToken ct)
        => ApplyTerminalOperationTransitionAsync(nameof(IncrementOperationFailedAsync), tenantId, branchId, occurredAtUtc, messageId, correlationId,
            () => _operationSet.IncrementOperationFailedAsync(tenantId, branchId, occurredAtUtc, ct), ct);

    private async Task ApplyTerminalOperationTransitionAsync(
        string eventName,
        Guid tenantId,
        Guid? branchId,
        DateTimeOffset occurredAtUtc,
        Guid? messageId,
        Guid? correlationId,
        Func<Task> applySet,
        CancellationToken ct)
    {
        await using var tx = await _store.BeginTransactionAsync(ct);

        if (!await _store.TryRegisterProcessedEventAsync(eventName, messageId, correlationId, tenantId, ct))
        {
            await tx.RollbackAsync(ct);
            return;
        }

        await applySet();

        await tx.CommitAsync(ct);
    }
}