using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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

            //! customere push bildirim göndeririz.
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

            //! teknisyene push bildirim göndeririz.
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
            if (operation == null)                return false;
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
    }
}