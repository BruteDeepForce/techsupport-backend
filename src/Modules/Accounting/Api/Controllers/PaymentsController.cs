using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;
using TechSupport.Accounting.Services;

namespace TechSupport.Accounting.Api.Controllers;

[ApiController]
[Route("api/accounting/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _paymentService;

    public PaymentsController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    /// <summary>
    /// Get payment by ID
    /// </summary>
    [HttpGet("{paymentId:guid}")]
    public async Task<ActionResult<PaymentResponse>> GetById(Guid paymentId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var payment = await _paymentService.GetByIdAsync(tenantId, paymentId);
        if (payment == null)
            return NotFound();

        return Ok(MapToResponse(payment));
    }

    /// <summary>
    /// Get payment by payment number
    /// </summary>
    [HttpGet("by-number/{paymentNumber}")]
    public async Task<ActionResult<PaymentResponse>> GetByNumber(string paymentNumber)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var payment = await _paymentService.GetByNumberAsync(tenantId, paymentNumber);
        if (payment == null)
            return NotFound();

        return Ok(MapToResponse(payment));
    }

    /// <summary>
    /// List payments with pagination and filters
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<PagedPaymentResponse>> List(
        [FromQuery] Guid? accountId = null,
        [FromQuery] Guid? invoiceId = null,
        [FromQuery] PaymentStatus? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _paymentService.ListAsync(tenantId, accountId, invoiceId, status, page, pageSize);
        return Ok(result);
    }

    /// <summary>
    /// Create a new payment
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<PaymentResponse>> Create([FromBody] CreatePaymentRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var payment = await _paymentService.CreateAsync(tenantId, request, User.Identity?.Name);
            return CreatedAtAction(nameof(GetById), new { paymentId = payment.Id }, MapToResponse(payment));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Process (complete) a payment
    /// </summary>
    [HttpPost("{paymentId:guid}/process")]
    public async Task<ActionResult<PaymentResponse>> Process(Guid paymentId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var payment = await _paymentService.ProcessAsync(tenantId, paymentId);
            if (payment == null)
                return NotFound();

            return Ok(MapToResponse(payment));
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Mark payment as failed
    /// </summary>
    [HttpPost("{paymentId:guid}/fail")]
    public async Task<ActionResult<PaymentResponse>> Fail(Guid paymentId, [FromQuery] string? reason = null)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var payment = await _paymentService.FailAsync(tenantId, paymentId, reason);
        if (payment == null)
            return NotFound();

        return Ok(MapToResponse(payment));
    }

    /// <summary>
    /// Refund a payment
    /// </summary>
    [HttpPost("{paymentId:guid}/refund")]
    public async Task<ActionResult<PaymentResponse>> Refund(Guid paymentId, [FromQuery] string? reason = null)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var payment = await _paymentService.RefundAsync(tenantId, paymentId, reason);
            if (payment == null)
                return NotFound();

            return Ok(MapToResponse(payment));
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Extracts TenantId from JWT claims
    /// </summary>
    private Guid GetTenantIdFromClaims()
    {
        var tenantIdClaim = User.FindFirst("tenantId") 
            ?? User.FindFirst("tenant_id");
        return tenantIdClaim != null ? Guid.Parse(tenantIdClaim.Value) : Guid.Empty;
    }

    /// <summary>
    /// Extracts BranchId from JWT claims (nullable)
    /// </summary>
    private Guid? GetBranchIdFromClaims()
    {
        var branchIdClaim = User.FindFirst("branchId") 
            ?? User.FindFirst("branch_id");
        return branchIdClaim != null ? Guid.Parse(branchIdClaim.Value) : null;
    }

    private static PaymentResponse MapToResponse(Payment payment)
    {
        return new PaymentResponse
        {
            Id = payment.Id,
            TenantId = payment.TenantId,
            AccountId = payment.AccountId,
            AccountName = payment.Account?.Name,
            InvoiceId = payment.InvoiceId,
            InvoiceNumber = payment.Invoice?.InvoiceNumber,
            PaymentNumber = payment.PaymentNumber,
            Method = payment.Method,
            Status = payment.Status,
            Amount = payment.Amount,
            FeeAmount = payment.FeeAmount,
            NetAmount = payment.NetAmount,
            ReferenceNumber = payment.ReferenceNumber,
            Notes = payment.Notes,
            PaymentDate = payment.PaymentDate,
            ProcessedAtUtc = payment.ProcessedAtUtc,
            CreatedAtUtc = payment.CreatedAtUtc,
            CreatedBy = payment.CreatedBy,
            UpdatedAtUtc = payment.UpdatedAtUtc,
            UpdatedBy = payment.UpdatedBy
        };
    }
}
