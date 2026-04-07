using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Stock.DTO
{
    public sealed record CreateItemDTO(
        Guid CategoryId,
        string Sku,
        string Barcode,
        string Name,
        string? Description,
        string? Unit,
        decimal? UnitPrice,
        long InitialQuantity);
}