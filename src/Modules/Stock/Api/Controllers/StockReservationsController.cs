using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TechSupport.Stock.DTO;
using TechSupport.Stock.Services;

namespace TechSupport.Stock.Api.Controllers;

[ApiController]
[Route("api/stock/reservations")]
public class StockReservationsController : ControllerBase
{
    private readonly IStockReserveService _reservations;

    public StockReservationsController(IStockReserveService reservations)
    {
        _reservations = reservations;
    }

    public record ReserveRequestBody(Guid StockItemId, Guid? OperationId, int Quantity, Guid? BranchId);

    private Guid? GetTenantIdFromClaims()
    {
        var tenantClaim = User.Claims.FirstOrDefault(c => c.Type == "tenant_id");
        return tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var tenantId) ? tenantId : null;
    }

    private Guid? GetTechnicianUserIdFromClaims()
    {
        var techClaim = User.Claims.FirstOrDefault(c => c.Type == "user_id")
            ?? User.Claims.FirstOrDefault(c => c.Type == "user_id");
        return techClaim != null && Guid.TryParse(techClaim.Value, out var techId) ? techId : null;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Reserve([FromBody] ReserveRequestBody body, CancellationToken ct)
    {
    var tenantId = GetTenantIdFromClaims();
    if (tenantId == null) return Unauthorized();

    var technicianId = GetTechnicianUserIdFromClaims();
    if (technicianId == null) return Unauthorized(new { error = "TechnicianId claim not found" });

        var request = new ReserveRequestDTO(
            tenantId.Value,
            body.StockItemId,
            technicianId.Value,
            body.OperationId,
            body.Quantity,
            body.BranchId);
        string IdempotentKey = $"{tenantId}:{body.StockItemId}:{body.OperationId}:{technicianId}:{body.Quantity}";


        var ok = await _reservations.ReserveStockAsync(request, IdempotentKey,ct);
        if (!ok) return BadRequest(new { error = "Reservation could not be created" });
        return Ok(new { status = "Pending" });
    }

    public record PublishOfferBody(Guid OperationId, decimal LaborAmount);

    [HttpPost("publish-offer")]
    [Authorize]
    public async Task<IActionResult> PublishOffer([FromBody] PublishOfferBody body, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId == null) return Unauthorized();
        var ok = await _reservations.PublishOperationOfferAsync(tenantId.Value, body.OperationId, body.LaborAmount, ct);
        if (!ok) return BadRequest(new { error = "Offer could not be published. Ensure there are approved reservations for this operation." });
        return Ok(new { status = "Offer Published" });
    }

    [Authorize(Roles = "admin")]
    [HttpPost("{reservationId:guid}/approve")]
    public async Task<IActionResult> Approve(Guid reservationId, CancellationToken ct)
    {
        var ok = await _reservations.ApproveReservationAsync(reservationId, ct);
        if (!ok) return NotFound(new { error = "Reservation not found or not in pending state" });
        return Ok(new { status = "Approved" });
    }

    [Authorize]
    [HttpPost("{reservationId:guid}/finalize")]
    public async Task<IActionResult> Finalize(Guid reservationId, CancellationToken ct)
    {
        var ok = await _reservations.FinalizeReservationAsync(reservationId, ct);
        if (!ok) return NotFound(new { error = "Reservation not found or not in approved state" });
        return Ok(new { status = "Finalized" });
    }

    [Authorize(Roles = "admin")]
    [HttpPost("{reservationId:guid}/reject")]
    public async Task<IActionResult> Reject(Guid reservationId, CancellationToken ct)
    {
        var ok = await _reservations.RejectReservationAsync(reservationId, ct);
        if (!ok) return NotFound(new { error = "Reservation not found or not in a rejectable state" });
        return Ok(new { status = "Rejected" });
    }

    [Authorize]
    [HttpPost("{reservationId:guid}/release")]
    public async Task<IActionResult> Release(Guid reservationId, CancellationToken ct)
    {
        var ok = await _reservations.ReleaseReservationAsync(reservationId, ct);
        if (!ok) return NotFound(new { error = "Reservation not found or not in a releasable state" });
        return Ok(new { status = "Released" });
    }
}
