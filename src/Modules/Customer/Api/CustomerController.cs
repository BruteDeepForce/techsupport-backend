using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Customer.Services;

namespace TechSupport.Customer.Api.Controllers
{
    [ApiController]
    [Route("api/customers")]
    public class CustomerController : ControllerBase
    {
        private readonly ICustomerService _customers;

        public CustomerController(ICustomerService customers)
        {
            _customers = customers;
        }

        public sealed record CreateCustomerDto(string Name, string Email, string? PhoneNumber, string TemporaryPassword);
    public sealed record AssignDeviceDto(Guid DeviceId, string? DeviceSerialNumber, string? BarcodeNumber, string? ProblemDescription, string? Model, string? Status);

        [Authorize(Roles = "admin")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCustomerDto dto, CancellationToken ct)
        {
            var tenantId = GetTenantIdFromClaims();
            var branchId = GetBranchIdFromClaims();
            if (tenantId is null) return Unauthorized();

            var request = await _customers.StartProvisioningAsync(tenantId.Value, branchId, dto.Name, dto.Email, 
            dto.PhoneNumber, dto.TemporaryPassword, null, null, ct);
            return Accepted(new
            {
                correlationId = request.CorrelationId,
                status = request.Status.ToString()
            });
        }

        [Authorize]
        [HttpGet]
        public async Task<IActionResult> List(CancellationToken ct)
        {
            var tenantId = GetTenantIdFromClaims();
            if (tenantId is null) return Unauthorized();

            var customers = await _customers.ListAsync(tenantId.Value, ct);
            return Ok(customers);
        }

        [Authorize]
        [HttpGet("{customerId:guid}")]
        public async Task<IActionResult> Get([FromRoute] Guid customerId, CancellationToken ct)
        {
            var tenantId = GetTenantIdFromClaims();
            if (tenantId is null) return Unauthorized();

            var customer = await _customers.GetByIdAsync(tenantId.Value, customerId, ct);
            return customer is null ? NotFound() : Ok(customer);
        }

        [Authorize]
        [HttpGet("provisioning/{correlationId:guid}")]
        public async Task<IActionResult> GetProvisioningStatus([FromRoute] Guid correlationId, CancellationToken ct)
        {
            var status = await _customers.GetProvisioningStatusAsync(correlationId, ct);
            if (status is null) return NotFound();

            return Ok(new
            {
                status.CorrelationId,
                Status = status.Status.ToString(),
                status.CustomerId,
                status.AppUserId,
                status.FailureReason,
                status.CreatedAtUtc,
                status.CompletedAtUtc
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPost("{customerId:guid}/devices")]
        public async Task<IActionResult> AssignDevice([FromRoute] Guid customerId, [FromBody] AssignDeviceDto dto, CancellationToken ct)
        {
            var tenantId = GetTenantIdFromClaims();
            var branchId = GetBranchIdFromClaims();
            if (tenantId is null) return Unauthorized();

            var assigned = await _customers.AssignDeviceToCustomerAsync(
                tenantId.Value,
                branchId,
                customerId,
                null,
                dto.DeviceId,
                dto.DeviceSerialNumber?.Trim(),
                dto.BarcodeNumber?.Trim(),
                dto.ProblemDescription?.Trim(),
                dto.Model?.Trim(),
                dto.Status ?? string.Empty,
                ct);
            return assigned ? Ok() : NotFound();
        }

        private Guid? GetTenantIdFromClaims()
        {
            var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
            return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
        }

        private Guid? GetBranchIdFromClaims()
        {
            var branchClaim = User.Claims.FirstOrDefault(c => c.Type == "branch_id");
            return branchClaim != null && Guid.TryParse(branchClaim.Value, out var branchId) ? branchId : null;
        }
    }
}