using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Stock.DTO;

namespace TechSupport.Stock.Services
{
    public interface IStockReserveService
    {
        Task<bool> ReserveStockAsync(ReserveRequestDTO request, CancellationToken cancellationToken = default);
        Task<bool> PublishOperationOfferAsync(Guid tenantId, Guid operationId, CancellationToken cancellationToken = default);
        Task<bool> ApproveReservationAsync(Guid reservationId, CancellationToken cancellationToken = default);
        Task<bool> FinalizeReservationAsync(Guid reservationId, CancellationToken cancellationToken = default);
        Task<bool> ReleaseReservationAsync(Guid reservationId, CancellationToken cancellationToken = default);
        Task<bool> RejectReservationAsync(Guid reservationId, CancellationToken cancellationToken = default);
    }
}