using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Operation.Services;

namespace TechSupport.Operation.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OfferController : ControllerBase
    {
        private readonly IOfferService offerService;

        public OfferController(IOfferService offerService)
        {
            this.offerService = offerService;
        }

        [HttpGet("offers/admin")]
        public async Task<IActionResult> GetAdminOffers(CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var branchId = GetBranchIdFromClaims();
            if (tenantId == Guid.Empty) return Unauthorized();

            if (branchId.HasValue)
            {
                var offersBranch = await offerService.GetOffersToAdminAsync(tenantId, branchId, ct);
                return Ok(offersBranch);
            }
            var offers = await offerService.GetOffersToAdminAsync(tenantId, null, ct);
            return Ok(offers);
        }

        [HttpGet("offers/customer")]
        public async Task<IActionResult> GetCustomerOffers(CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var userId = GetUserIdFromClaims();
            var branchId = GetBranchIdFromClaims();
            if (tenantId == Guid.Empty || userId == Guid.Empty) return Unauthorized();
            if(branchId.HasValue)
            {
                var offersBranch = await offerService.GetOffersToCustomerAsync(tenantId, branchId, userId, ct);
                 return Ok(offersBranch);
            }
            var offers = await offerService.GetOffersToCustomerAsync(tenantId, null, userId, ct);

            return Ok(offers);
        }

        [HttpGet("{offerid}/offer")]
        public async Task<IActionResult> GetById (Guid offerid, CancellationToken ct)
        {
            var tenant_id = GettenantIdFromClaims();
            var branch_id = GetBranchIdFromClaims();
            if (tenant_id == Guid.Empty)
            return Unauthorized();
            if(branch_id.HasValue)
            {
                var result = await offerService.GetOfferByIdAsync(tenant_id, branch_id, offerid,ct);
                return Ok(result);
            }
            var resultNoBranch = await offerService.GetOfferByIdAsync(tenant_id, null, offerid,ct);
            return Ok(resultNoBranch);
        }

        [HttpPost("approve/admin/{offerid}")]
        public async Task<IActionResult> ApproveAdmin(Guid offerid, CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var branch_id = GetBranchIdFromClaims();
            
            if(tenantId == Guid.Empty) return Unauthorized();

            if(branch_id.HasValue)
            {
                var resultBranch = await offerService.AdminApproveOfferAsync(tenantId, branch_id, offerid, ct);
                if (!resultBranch) return BadRequest();
                return Ok(resultBranch);
            }
            var result = await offerService.AdminApproveOfferAsync(tenantId,branch_id,offerid,ct);
            if (!result) return BadRequest();
            return Ok(result);
        }
        [HttpPost("approve/customer/{offerid}")]
        public async Task<IActionResult> ApproveCustomer(Guid offerid, CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var userId = GetUserIdFromClaims();
            var branch_id = GetBranchIdFromClaims();
            
            if(tenantId == Guid.Empty || userId == Guid.Empty) return Unauthorized();

            if(branch_id.HasValue)
            {
                var resultBranch = await offerService.CustomerAcceptOfferAsync(tenantId, branch_id, offerid, userId, ct);
                if (!resultBranch) return BadRequest();
                return Ok(resultBranch);
            }
            var result = await offerService.CustomerAcceptOfferAsync(tenantId, null, offerid, userId, ct);
            if (!result) return BadRequest();
            return Ok(result);
        }
        [HttpPost("reject/admin/{offerid}")]
        public async Task<IActionResult> RejectAdmin(Guid offerid, CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var branch_id = GetBranchIdFromClaims();

            if(tenantId == Guid.Empty) return Unauthorized();

            if(branch_id.HasValue)
            {
                var resultBranch = await offerService.AdminRejectOfferAsync(tenantId, branch_id, offerid, ct);
                if (!resultBranch) return BadRequest();
                return Ok(resultBranch);
            }
            var result = await offerService.AdminRejectOfferAsync(tenantId, null, offerid, ct);
            if (!result) return BadRequest();
            return Ok(result);
        }
        [HttpPost("reject/customer/{offerid}")]
        public async Task<IActionResult> RejectCustomer(Guid offerid, CancellationToken ct)
        {
            var tenantId = GettenantIdFromClaims();
            var userId = GetUserIdFromClaims();
            var branch_id = GetBranchIdFromClaims();
            if(tenantId == Guid.Empty || userId == Guid.Empty) return Unauthorized();

            if(branch_id.HasValue)
            {
                var resultBranch = await offerService.CustomerRejectOfferAsync(tenantId, branch_id, offerid, userId, ct);
                if (!resultBranch) return BadRequest();
                return Ok(resultBranch);
            }
            var result = await offerService.CustomerRejectOfferAsync(tenantId, null, offerid, userId, ct);
            if (!result) return BadRequest();
            return Ok(result);
        }
        private Guid GettenantIdFromClaims()
        {
            var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
            return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : Guid.Empty;
        }

        private Guid? GetBranchIdFromClaims()
        {
            var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id");
            return branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId) ? branchId : null;
        }

        private Guid GetUserIdFromClaims()
        {
            var userClaim = User.Claims.FirstOrDefault(c => c.Type == "user_id");
            return userClaim != null && Guid.TryParse(userClaim.Value, out var userId) ? userId : Guid.Empty;
        }
    }
}