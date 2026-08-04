using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Trade.Services;

namespace TechSupport.Trade.Api.Controllers;

[ApiController]
[Route("api/trade/quick-sales")]
public sealed class QuickSalesController : ControllerBase
{
    private readonly IQuickSaleService _quickSales;

    public QuickSalesController(IQuickSaleService quickSales)
    {
        _quickSales = quickSales;
    }

    public sealed record QuickSaleLineDto(Guid StockItemId, int Quantity, decimal? UnitPriceOverride);
    public sealed record CreateQuickSaleDto(IReadOnlyList<QuickSaleLineDto> Lines, decimal DiscountAmount, decimal PaidAmount, string PaymentMethod, string Currency, string? Note);

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var quickSales = await _quickSales.GetAllAsync(tenantId.Value, ct);
        return Ok(quickSales.Select(ToResponse));
    }

    [Authorize(Roles = "admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateQuickSaleDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        var branchId = GetBranchIdFromClaims();
        if (tenantId is null) return Unauthorized();

        var quickSale = await _quickSales.CreateAsync(new CreateQuickSaleRequest(
            tenantId.Value,
            branchId,
            dto.Lines.Select(x => new QuickSaleLineRequest(x.StockItemId, x.Quantity, x.UnitPriceOverride)).ToList(),
            dto.DiscountAmount,
            dto.PaidAmount,
            dto.PaymentMethod,
            dto.Currency,
            dto.Note), ct);

        return Ok(ToResponse(quickSale));
    }

    private static object ToResponse(TechSupport.Trade.Domain.Entities.QuickSale quickSale) => new
    {
        quickSale.Id,
        quickSale.SaleNumber,
        status = quickSale.Status.ToString(),
        quickSale.SubtotalAmount,
        quickSale.DiscountAmount,
        quickSale.TotalAmount,
        quickSale.PaidAmount,
        quickSale.PaymentMethod,
        quickSale.Currency,
        quickSale.Note,
        quickSale.CreatedAtUtc,
        lines = quickSale.Lines.Select(x => new
        {
            x.Id,
            x.StockItemId,
            x.ProductName,
            x.Sku,
            x.Quantity,
            x.UnitPrice,
            x.LineTotal
        })
    };

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
