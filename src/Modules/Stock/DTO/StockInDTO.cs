namespace TechSupport.Stock.DTO;

public sealed record StockInDTO(
    long Quantity,
    string? Reference = null
);
