using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit.Initializers.PropertyConverters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TechSupport.Operation.Data;
using TechSupport.Operation.Domain.Entities;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Services
{
    public class OfferService : IOfferService
    {
        private readonly OperationDbContext _dbContext;

        public OfferService(OperationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<bool> AdminApproveOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct)
        {
            if (offerId == Guid.Empty)
                throw new ArgumentException("Offer ID cannot be empty.", nameof(offerId));
            var offer = await _dbContext.OfferRecords.FirstOrDefaultAsync(o => o.Id == offerId && o.TenantId == TenantId, ct);
            if (offer == null)
                return false;

            offer.Status = OfferStatus.AdminApproved;
            offer.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(ct);

            //! teknisyen ve customere push bildirim göndeririz. daha sonra teknisyen işi başlatır.
            return true;
        }

        public async Task<bool> AdminRejectOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct)
        {
            var offer = await _dbContext.OfferRecords.FirstOrDefaultAsync(o => o.Id == offerId && o.TenantId == TenantId, ct);
            if (offer == null)
                return false;

            offer.Status = OfferStatus.AdminRejected;
            offer.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(ct);

            //! customera push bildirim göndeririz.
            return true;
        }

        public async Task<bool> CustomerAcceptOfferAsync(Guid TenantId, Guid? BranchId,
        Guid offerId, Guid CustomerId, CancellationToken ct)
        {
            using var transaction = await _dbContext.Database.BeginTransactionAsync(ct);
            if (offerId == Guid.Empty || CustomerId == Guid.Empty || TenantId == Guid.Empty)
                throw new ArgumentException("Offer ID, Customer ID, and Tenant ID cannot be empty.");
            var offer = await _dbContext.OfferRecords.FirstOrDefaultAsync(o => o.Id == offerId && o.TenantId == TenantId && o.CustomerId == CustomerId, ct);
            if (offer == null)
                return false;
            offer.Status = OfferStatus.CustomerApproved;
            offer.UpdatedAt = DateTime.UtcNow;

            var operationId = offer.OperationId;
            var operation = await _dbContext.Operations.FirstOrDefaultAsync(o => o.Id == operationId && o.TenantId == TenantId, ct);
            if (operation == null) return false;
            operation.Status = OperationStatus.Diagnosing;
            await _dbContext.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);

            //! teknisyene ve customera push bildirim göndeririz.
            //! Stock modülüne StockReserve için Approved eventi publish ederiz.
            return true;
        }

        public async Task<bool> CustomerRejectOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, Guid CustomerId, CancellationToken ct)
        {
            if (offerId == Guid.Empty || CustomerId == Guid.Empty || TenantId == Guid.Empty)
                throw new ArgumentException("Offer ID, Customer ID, and Tenant ID cannot be empty.");
            var offer = await _dbContext.OfferRecords.FirstOrDefaultAsync(o => o.Id == offerId && o.TenantId == TenantId && o.CustomerId == CustomerId, ct);
            if (offer == null)
                return false;
            offer.Status = OfferStatus.CustomerRejected;
            offer.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(ct);

            //! teknisyene ve customera push bildirim göndeririz.
            return true;
        }

        public async Task<bool> TechnicianCreateOfferAsync(OfferDTO offer, CancellationToken ct)
        {
            if (offer.Items == null || !offer.Items.Any())
                return false;

            var offerRecord = new Domain.Entities.OfferRecord
            {
                Id = Guid.NewGuid(),
                TenantId = offer.TenantId,
                BranchId = offer.BranchId,
                OperationId = offer.OperationId,
                TechnicianUserId = offer.TechnicianUserId,
                CustomerId = offer.CustomerId,
                Amount = offer.Items.Sum(i => i.Quantity * i.UnitPrice),
                Currency = offer.Currency,
                CreatedAt = DateTime.UtcNow,
                Items = offer.Items.Select(i => new OfferRecordItem
                {
                    Id = Guid.NewGuid(),
                    StockItemId = i.StockItemId,
                    Quantity = i.Quantity,
                    UnitPrice = i.UnitPrice
                }).ToList(),
                Status = OfferStatus.Pending
            };

            await _dbContext.OfferRecords.AddAsync(offerRecord, ct);
            await _dbContext.SaveChangesAsync(ct);

            //!admine push bildirim göndeririz.
            return true;
        }
        public async Task<IEnumerable<OfferDTO>> GetOffersToAdminAsync(Guid TenantId, Guid? BranchId, CancellationToken ct)
        {
            var query = await _dbContext.OfferRecords.AsNoTracking().Where(o => o.TenantId == TenantId).ToListAsync(ct);

            if (query == null || !query.Any())
                return Enumerable.Empty<OfferDTO>();

            var offers = query.Select(o => new OfferDTO(
                o.Id,
                o.TenantId,
                o.BranchId,
                o.OperationId,
                o.TechnicianUserId,
                o.CustomerId,
                o.Amount,
                o.Currency,
                o.CreatedAt,
                o.Items.Select(i => new OfferItemDTO(i.StockItemId, i.Quantity, i.UnitPrice))
            ));
            return offers;
        }
        public async Task<IEnumerable<OfferDTO>> GetOffersToCustomerAsync(Guid TenantId, Guid? BranchId, Guid CustomerId, CancellationToken ct)
        {
            var query = await _dbContext.OfferRecords.AsNoTracking().Where(o => o.TenantId == TenantId && o.CustomerId == CustomerId).ToListAsync(ct);

            if (query == null || !query.Any())
                return Enumerable.Empty<OfferDTO>();

            var offers = query.Select(o => new OfferDTO(
                o.Id,
                o.TenantId,
                o.BranchId,
                o.OperationId,
                o.TechnicianUserId,
                o.CustomerId,
                o.Amount,
                o.Currency,
                o.CreatedAt,
                o.Items.Select(i => new OfferItemDTO(i.StockItemId, i.Quantity, i.UnitPrice))
            ));
            return offers;
        }

        public async Task<OfferDTO?> GetOfferByIdAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct)
        {
            if(TenantId == Guid.Empty || offerId == Guid.Empty) return null;

            var offer = await _dbContext.OfferRecords.Include(x=> x.Items).FirstOrDefaultAsync(x=> x.Id == offerId, ct);
            if (offer != null)
            {
                return new OfferDTO(
                    offer.Id,
                    offer.TenantId,
                    offer.BranchId,
                    offer.OperationId,
                    offer.TechnicianUserId,
                    offer.CustomerId,
                    offer.Amount,
                    offer.Currency,
                    offer.CreatedAt,
                    offer.Items.Select(i => new OfferItemDTO(i.StockItemId, i.Quantity, i.UnitPrice))
                );
}
            return null;
        }
    }
}