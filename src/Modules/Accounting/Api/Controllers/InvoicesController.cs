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
[Route("api/accounting/invoices")]
[Authorize]
public class InvoicesController : ControllerBase
{
    private readonly IInvoiceService _invoiceService;
    private readonly IInvoicePdfService _invoicePdfService;

    public InvoicesController(IInvoiceService invoiceService, IInvoicePdfService invoicePdfService)
    {
        _invoiceService = invoiceService;
        _invoicePdfService = invoicePdfService;
    }

    /// <summary>
    /// Get invoice by ID
    /// </summary>
    [HttpGet("{invoiceId:guid}")]
    public async Task<ActionResult<InvoiceResponse>> GetById(Guid invoiceId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var invoice = await _invoiceService.GetByIdAsync(tenantId, invoiceId);
        if (invoice == null)
            return NotFound();

        return Ok(MapToResponse(invoice));
    }

    /// <summary>
    /// Download invoice as PDF
    /// </summary>
    [HttpGet("{invoiceId:guid}/pdf")]
    public async Task<IActionResult> DownloadPdf(Guid invoiceId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var invoice = await _invoiceService.GetByIdAsync(tenantId, invoiceId);
        if (invoice == null)
            return NotFound();

        var pdfBytes = _invoicePdfService.Generate(invoice);
        var fileName = $"{invoice.InvoiceNumber}.pdf";
        return File(pdfBytes, "application/pdf", fileName);
    }

    /// <summary>
    /// Get invoice by invoice number
    /// </summary>
    [HttpGet("by-number/{invoiceNumber}")]
    public async Task<ActionResult<InvoiceResponse>> GetByNumber(string invoiceNumber)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var invoice = await _invoiceService.GetByNumberAsync(tenantId, invoiceNumber);
        if (invoice == null)
            return NotFound();

        return Ok(MapToResponse(invoice));
    }

    /// <summary>
    /// List invoices with pagination and filters
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<PagedInvoiceResponse>> List(
        [FromQuery] Guid? accountId = null,
        [FromQuery] InvoiceStatus? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var result = await _invoiceService.ListAsync(tenantId, accountId, status, page, pageSize);
        return Ok(result);
    }

    /// <summary>
    /// Create a new invoice
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<InvoiceResponse>> Create([FromBody] CreateInvoiceRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var invoice = await _invoiceService.CreateAsync(tenantId, request, User.Identity?.Name);
            return CreatedAtAction(nameof(GetById), new { invoiceId = invoice.Id }, MapToResponse(invoice));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Update an invoice
    /// </summary>
    [HttpPut("{invoiceId:guid}")]
    public async Task<ActionResult<InvoiceResponse>> Update(Guid invoiceId, [FromBody] UpdateInvoiceRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            // Ensure the request contains the correct Id
            request.Id = invoiceId;
            var invoice = await _invoiceService.UpdateAsync(tenantId, request, User.Identity?.Name);
            if (invoice == null)
                return NotFound();

            return Ok(MapToResponse(invoice));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Add line item to invoice
    /// </summary>
    [HttpPost("{invoiceId:guid}/line-items")]
    public async Task<ActionResult<InvoiceResponse>> AddLineItem(Guid invoiceId, [FromBody] AddInvoiceLineItemRequest request)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var invoice = await _invoiceService.AddLineItemAsync(tenantId, invoiceId, request, User.Identity?.Name);
            if (invoice == null)
                return NotFound();

            return Ok(MapToResponse(invoice));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Remove line item from invoice
    /// </summary>
    [HttpDelete("{invoiceId:guid}/line-items/{lineItemId:guid}")]
    public async Task<ActionResult<InvoiceResponse>> RemoveLineItem(Guid invoiceId, Guid lineItemId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var invoice = await _invoiceService.RemoveLineItemAsync(tenantId, invoiceId, lineItemId);
        if (invoice == null)
            return NotFound();

        return Ok(MapToResponse(invoice));
    }

    /// <summary>
    /// Issue (finalize) an invoice
    /// </summary>
    [HttpPost("{invoiceId:guid}/issue")]
    public async Task<ActionResult<InvoiceResponse>> Issue(Guid invoiceId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var invoice = await _invoiceService.IssueAsync(tenantId, invoiceId);
            if (invoice == null)
                return NotFound();

            return Ok(MapToResponse(invoice));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Cancel an invoice
    /// </summary>
    [HttpPost("{invoiceId:guid}/cancel")]
    public async Task<ActionResult<InvoiceResponse>> Cancel(Guid invoiceId, [FromQuery] string? reason = null)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        try
        {
            var invoice = await _invoiceService.CancelAsync(tenantId, invoiceId, reason);
            if (invoice == null)
                return NotFound();

            return Ok(MapToResponse(invoice));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Get receivable amount for account
    /// </summary>
    [HttpGet("receivable/{accountId:guid}")]
    public async Task<ActionResult<decimal>> GetReceivable(Guid accountId)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var receivable = await _invoiceService.GetReceivableAsync(tenantId, accountId);
        return Ok(receivable);
    }

    /// <summary>
    /// Get total receivables for tenant
    /// </summary>
    [HttpGet("receivable")]
    public async Task<ActionResult<decimal>> GetTotalReceivables()
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == Guid.Empty)
            return Unauthorized(new { error = "TenantId claim not found" });

        var receivable = await _invoiceService.GetTotalReceivablesAsync(tenantId);
        return Ok(receivable);
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

    private static InvoiceResponse MapToResponse(Invoice invoice)
    {
        return new InvoiceResponse
        {
            Id = invoice.Id,
            TenantId = invoice.TenantId,
            AccountId = invoice.AccountId,
            AccountName = invoice.Account?.Name,
            InvoiceNumber = invoice.InvoiceNumber,
            Status = invoice.Status,
            Type = invoice.Type,
            IssueDate = invoice.IssueDate,
            DueDate = invoice.DueDate,
            PaidDate = invoice.PaidDate,
            Subtotal = invoice.Subtotal,
            TaxAmount = invoice.TaxAmount,
            TotalAmount = invoice.TotalAmount,
            PaidAmount = invoice.PaidAmount,
            Notes = invoice.Notes,
            CreatedAtUtc = invoice.CreatedAtUtc,
            CreatedBy = invoice.CreatedBy,
            UpdatedAtUtc = invoice.UpdatedAtUtc,
            UpdatedBy = invoice.UpdatedBy,
            LineItems = invoice.LineItems.Select(li => new InvoiceLineItemResponse
            {
                Id = li.Id,
                LineNumber = li.LineNumber,
                Description = li.Description,
                ProductCode = li.ProductCode,
                Quantity = li.Quantity,
                Unit = li.Unit,
                UnitPrice = li.UnitPrice,
                TaxRate = li.TaxRate,
                TaxAmount = li.TaxAmount,
                LineTotal = li.LineTotal
            }).ToList()
        };
    }
}
