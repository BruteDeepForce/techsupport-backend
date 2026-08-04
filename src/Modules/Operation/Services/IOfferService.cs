using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TechSupport.Operation.DTO;

namespace TechSupport.Operation.Services
{
    public interface IOfferService
    {
        Task<bool> TechnicianCreateOfferAsync(OfferDTO offer, CancellationToken ct);
        Task<bool> AdminApproveOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct);
        Task<bool> AdminRejectOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct);
        Task<bool> CustomerAcceptOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, Guid CustomerId, CancellationToken ct);
        Task<bool> CustomerRejectOfferAsync(Guid TenantId, Guid? BranchId, Guid offerId, Guid CustomerId, CancellationToken ct);
        Task<IEnumerable<OfferDTO>> GetOffersToAdminAsync(Guid TenantId, Guid? BranchId, CancellationToken ct);
        Task<IEnumerable<OfferDTO>> GetOffersToCustomerAsync(Guid TenantId, Guid? BranchId, Guid CustomerId, CancellationToken ct);
        Task<OfferDTO?> GetOfferByIdAsync(Guid TenantId, Guid? BranchId, Guid offerId, CancellationToken ct);
    }
}