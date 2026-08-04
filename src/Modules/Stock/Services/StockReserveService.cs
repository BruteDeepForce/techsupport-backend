using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Stock.Contracts.Events;
using TechSupport.Stock.Data;
using TechSupport.Stock.Domain.Entities;
using TechSupport.Stock.DTO;
using TechSupport.Stock.Services;

namespace TechSupport.Stock.Services
{
    public class StockReserveService : IStockReserveService
    {
        private readonly IBus _bus;
        private readonly StockDbContext _dbContext;
        public StockReserveService(StockDbContext dbContext, IBus bus)
        {
            _dbContext = dbContext;
            _bus = bus;
        }
        [Obsolete("publish event ile operasyon modülünde teklif create edilecek.reports modülüne rapor düşecek.ai modülüne gönderilecek.")]
        public async Task<bool> ReserveStockAsync(ReserveRequestDTO request, string IdempotentKey, CancellationToken cancellationToken = default)
        {
            //! need idempotent Task 
            //! need ATOMIC update task
            //! Prevent Race Condition  


            await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);
            var isExist = await _dbContext.StockItems.Include(x => x.Balances).FirstOrDefaultAsync(s => s.Id == request.StockItemId && s.TenantId == request.TenantId, cancellationToken);
            var totalAvailable = isExist?.Balances.Sum(x => x.QuantityAvailable) ?? 0;

            if (isExist == null)
                throw new ArgumentException("Stock item does not exist.", nameof(request.StockItemId));

            if (request.Quantity <= 0 || request.TenantId == Guid.Empty ||
            request.StockItemId == Guid.Empty
            || request.TechnicianUserId == Guid.Empty
            || request.Quantity > isExist.Balances.Where(x => x.StockItemId == request.StockItemId).Sum(x => x.QuantityAvailable)
            || totalAvailable - request.Quantity < 0)
            {
                return false;
            }

            string idempotencyKey = IdempotentKey;

            var inserted = await _dbContext.Database.ExecuteSqlRawAsync(@"
            INSERT INTO stock.""stock_reservations"" (
            ""Id"",
            ""TenantId"",
            ""StockItemId"",
            ""TechnicianUserId"",
            ""OperationId"",
            ""Quantity"",
            ""BranchId"",
            ""Status"",
            ""CreatedAtUtc"",
            ""RequestedAtUtc"",
            ""UnitPriceSnapshot"",
            ""IdempotentcyKey""
        )
        VALUES (
                    {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}
                )
        ON CONFLICT (""IdempotentcyKey"") DO NOTHING",

            Guid.NewGuid(),
            request.TenantId,
            request.StockItemId,
            request.TechnicianUserId,
            request.OperationId,
            request.Quantity,
            request.BranchId ?? Guid.Empty,
            (int)StockReservationStatus.Pending,
            DateTime.UtcNow,
            DateTime.UtcNow,
            isExist.UnitPrice ?? 0m,
            idempotencyKey
);
        if(inserted == 0 )
            {
                await transaction.RollbackAsync(cancellationToken);
                return false;
            }

            // var reservation = new StockReservation
            // {
            //     Id = Guid.NewGuid(),
            //     TenantId = request.TenantId,
            //     StockItemId = request.StockItemId,
            //     TechnicianUserId = request.TechnicianUserId,
            //     OperationId = request.OperationId,
            //     Quantity = request.Quantity,
            //     BranchId = request.BranchId,
            //     Status = StockReservationStatus.Pending,
            //     RequestedAtUtc = DateTime.UtcNow,
            //     UnitPriceSnapshot = isExist.UnitPrice
            // };

            // await _dbContext.StockReservations.AddAsync(reservation, cancellationToken);

            var balance = isExist.Balances.FirstOrDefault(x => x.StockItemId == request.StockItemId);
            if (balance != null)
            {
                var affected = await _dbContext.StockBalances
                .Where(x=> x.StockItemId == request.StockItemId 
                && x.QuantityAvailable >= request.Quantity)
                .ExecuteUpdateAsync( property => property
                .SetProperty(x=> x.QuantityReserved, x=> x.QuantityReserved + request.Quantity)
                .SetProperty(x=> x.QuantityAvailable, x=> x.QuantityAvailable - request.Quantity));
                if(affected == 0)
                {
                    await transaction.RollbackAsync(cancellationToken);
                    return false;
                }
                await transaction.CommitAsync(cancellationToken);
                return true;
            }

            return false;
        }

        public async Task<bool> PublishOperationOfferAsync(Guid tenantId, Guid operationId, decimal LaborAmount, CancellationToken cancellationToken = default)
        {
            if (tenantId == Guid.Empty)
                throw new ArgumentException("Tenant ID cannot be empty.", nameof(tenantId));
            if (operationId == Guid.Empty)
                throw new ArgumentException("Operation ID cannot be empty.", nameof(operationId));

        //*
            var stockItemS = await _dbContext.StockItems.Include(x=> x.Reservations)
            .Where(x=> x.Reservations.Any(r => r.OperationId == operationId && r.TenantId == tenantId))
            .ToListAsync(cancellationToken);

            if(stockItemS.Count == 0)
                return false;

            var items = stockItemS.SelectMany(s => s.Reservations.Where(r => r.OperationId == operationId && r.TenantId == tenantId)
            .GroupBy(r => new { r.StockItemId, UnitPriceSnapshot = r.UnitPriceSnapshot ?? 0m })
            .Select(group => new StockOperationOfferItem(
                group.Key.StockItemId,
                s.Name,
                group.Sum(r => r.Quantity),
                group.Key.UnitPriceSnapshot)
        ))
            .ToList();

            if(items.Count == 0)
                return false;

            // var reservations = await _dbContext.StockReservations
            //     .Where(r => r.TenantId == tenantId && r.OperationId == operationId)
            //     .ToListAsync(cancellationToken);

            // if (reservations.Count == 0)
            //     return false;

            //! groupby ile aynı stock item id ve unit price snapshot'a sahip rezervasyonları birleştiriyoruz. 
            //!Böylece operasyon teklifi oluştururken her bir stok kalemi için toplam miktarı ve fiyatı alabiliriz. 
            //!Bu, teklif oluşturma sürecini basitleştirir ve aynı stok kalemi için birden fazla rezervasyon varsa 
            //!bunları tek bir kalem olarak sunmamızı sağlar.

            // var items = reservations
            //     .GroupBy(r => new { r.StockItemId, UnitPriceSnapshot = r.UnitPriceSnapshot ?? 0m })
            //     .Select(group => new StockOperationOfferItem(
            //         group.Key.StockItemId,
            //         group.Sum(r => r.Quantity),
            //         group.Key.UnitPriceSnapshot))
            //     .ToList();

            var totalAmount = items.Sum(i => i.UnitPriceSnapshot * i.Quantity);

            var sample = stockItemS
                .Select(s => s.Reservations.FirstOrDefault(r => r.OperationId == operationId && r.TenantId == tenantId))
                .FirstOrDefault();

            //* 

            var technicianUserId = sample.TechnicianUserId ?? Guid.Empty;
            //! burada teklif giderken name bilgileri gitmesi lazım itemler için.
            //! solved gidiyor. ayrıca laboramount işçilik ücreti de gidiyor.

            //! operation modülüne publish oluyor.....//
            await _bus.Publish(new StockOperationOfferRequested(
                TenantId: tenantId,
                OperationId: operationId,
                BranchId: sample.BranchId,
                TechnicianUserId: technicianUserId,
                TotalAmount: totalAmount + LaborAmount,
                LaborAmount: LaborAmount,
                Items: items,
                OccurredAtUtc: DateTimeOffset.UtcNow
            ), cancellationToken);

            return true;
        }
        public async Task<bool> ApproveReservationAsync(Guid reservationId, CancellationToken cancellationToken = default)
        {
            var reservation = await _dbContext.StockReservations
                .FirstOrDefaultAsync(r => r.Id == reservationId, cancellationToken);
            if (reservation == null)
                return false;

            if (reservation.Status != StockReservationStatus.Pending)
                return false;

            reservation.Status = StockReservationStatus.Approved;
            reservation.ApprovedAtUtc = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(cancellationToken);
            return true;
        }

        public async Task<bool> FinalizeReservationAsync(Guid reservationId, CancellationToken cancellationToken = default)
        {
            await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);

            var reservation = await _dbContext.StockReservations
                .FirstOrDefaultAsync(r => r.Id == reservationId, cancellationToken);
            if (reservation == null)
                return false;

            if (reservation.Status != StockReservationStatus.Approved)
                return false;

            var balance = await _dbContext.StockBalances
                .FirstOrDefaultAsync(b => b.TenantId == reservation.TenantId
                    && b.StockItemId == reservation.StockItemId
                    && b.BranchId == reservation.BranchId, cancellationToken);

            if (balance == null || balance.QuantityReserved < reservation.Quantity)
                return false;

            balance.QuantityReserved -= reservation.Quantity;
            balance.QuantityAvailable -= reservation.Quantity;

            reservation.Status = StockReservationStatus.Finalized;
            reservation.FinalizedAtUtc = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return true;
        }

        public async Task<bool> RejectReservationAsync(Guid reservationId, CancellationToken cancellationToken = default)
        {
            await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);

            var reservation = await _dbContext.StockReservations
                .FirstOrDefaultAsync(r => r.Id == reservationId, cancellationToken);
            if (reservation == null)
                return false;

            if (reservation.Status != StockReservationStatus.Pending && reservation.Status != StockReservationStatus.Approved)
                return false;

            var balance = await _dbContext.StockBalances
                .FirstOrDefaultAsync(b => b.TenantId == reservation.TenantId
                    && b.StockItemId == reservation.StockItemId
                    && b.BranchId == reservation.BranchId, cancellationToken);

            if (balance != null)
            {
                balance.QuantityReserved = Math.Max(0, balance.QuantityReserved - reservation.Quantity);
            }

            reservation.Status = StockReservationStatus.Rejected;
            reservation.RejectedAtUtc = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return true;
        }

        public async Task<bool> ReleaseReservationAsync(Guid reservationId, CancellationToken cancellationToken = default)
        {
            await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);

            var reservation = await _dbContext.StockReservations
                .FirstOrDefaultAsync(r => r.Id == reservationId, cancellationToken);
            if (reservation == null)
                return false;

            if (reservation.Status != StockReservationStatus.Pending && reservation.Status != StockReservationStatus.Approved)
                return false;

            var balance = await _dbContext.StockBalances
                .FirstOrDefaultAsync(b => b.TenantId == reservation.TenantId
                    && b.StockItemId == reservation.StockItemId
                    && b.BranchId == reservation.BranchId, cancellationToken);

            if (balance != null)
            {
                balance.QuantityReserved = Math.Max(0, balance.QuantityReserved - reservation.Quantity);
            }

            reservation.Status = StockReservationStatus.Released;
            reservation.ReleasedAtUtc = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return true;
        }

    }
}