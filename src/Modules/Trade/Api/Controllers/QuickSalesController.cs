using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.Services;

namespace TechSupport.Trade.Api.Controllers;

[ApiController]
[Authorize(Roles = "admin")]
[Route("api/trade/quick-sales")]
public sealed class QuickSalesController : ControllerBase
{
    private readonly IQuickSaleService _service;

    public QuickSalesController(IQuickSaleService service) => _service = service;

    public sealed record CreateItemDto(Guid StockItemId, long Quantity);
    public sealed record CreateDto(
        string IdempotencyKey,
        QuickSalePaymentMethod PaymentMethod,
        decimal DiscountAmount,
        decimal? PaidAmount,
        IReadOnlyList<CreateItemDto> Items);

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDto request, CancellationToken ct)
    {
        if (!TryGetRequiredClaims(out var tenantId, out var branchId, out var userId))
            return Unauthorized();

        try
        {
            var sale = await _service.CreateAsync(new CreateQuickSaleRequest(
                tenantId,
                branchId,
                userId,
                request.IdempotencyKey,
                request.PaymentMethod,
                request.DiscountAmount,
                request.PaidAmount,
                request.Items.Select(x => new CreateQuickSaleLineRequest(x.StockItemId, x.Quantity)).ToList()), ct);

            return AcceptedAtAction(nameof(GetById), new { quickSaleId = sale.Id }, ToResponse(sale));
        }
        catch (ArgumentException exception)
        {
            return BadRequest(new { error = exception.Message });
        }
    }

    [HttpGet("{quickSaleId:guid}")]
    public async Task<IActionResult> GetById(Guid quickSaleId, CancellationToken ct)
    {
        var tenantId = ClaimGuid("tenant_id");
        if (!tenantId.HasValue) return Unauthorized();
        var sale = await _service.GetAsync(tenantId.Value, quickSaleId, ct);
        return sale is null ? NotFound() : Ok(ToResponse(sale));
    }

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var tenantId = ClaimGuid("tenant_id");
        var branchId = ClaimGuid("branch_id");
        if (!tenantId.HasValue || !branchId.HasValue) return Unauthorized();
        var sales = await _service.ListAsync(tenantId.Value, branchId.Value, new QuickSaleListRequest(page, pageSize), ct);
        return Ok(sales.Select(ToResponse));
    }

    private bool TryGetRequiredClaims(out Guid tenantId, out Guid branchId, out Guid userId)
    {
        tenantId = ClaimGuid("tenant_id") ?? Guid.Empty;
        branchId = ClaimGuid("branch_id") ?? Guid.Empty;
        userId = ClaimGuid("user_id") ?? Guid.Empty;
        return tenantId != Guid.Empty && branchId != Guid.Empty && userId != Guid.Empty;
    }

    private Guid? ClaimGuid(string type)
    {
        var value = User.Claims.FirstOrDefault(x => x.Type == type)?.Value;
        return Guid.TryParse(value, out var parsed) ? parsed : null;
    }

    private static object ToResponse(QuickSale sale) => new
    {
        quickSaleId = sale.Id,
        sale.SaleNumber,
        status = sale.Status.ToString(),
        paymentMethod = sale.PaymentMethod.ToString(),
        sale.Subtotal,
        sale.DiscountAmount,
        sale.TotalAmount,
        sale.PaidAmount,
        sale.AccountingInvoiceId,
        sale.AccountingPaymentId,
        sale.FailureReason,
        sale.CreatedAtUtc,
        sale.CompletedAtUtc,
        items = sale.Items.Select(x => new
        {
            x.StockItemId,
            x.ProductNameSnapshot,
            x.SkuSnapshot,
            x.BarcodeSnapshot,
            x.Quantity,
            x.UnitPriceSnapshot,
            x.LineTotal
        })
    };
}
