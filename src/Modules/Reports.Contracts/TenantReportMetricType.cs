namespace TechSupport.Reports.Contracts;

public enum TenantReportMetricType
{
    CustomerCreated = 1,
    OperationCreated = 2,
    OperationCompleted = 3,
    OperationDelivered = 4,
    OperationFailed = 5,
    OpenOperation = 6,
    OperationCancelled = 7,

    OfferCreated = 8,
    OfferAccepted = 9,
    OfferRejected = 10,

    TicketCreated = 11,
    TicketConvertedToOperation = 12,
    TicketClosed = 13,

    TradeSale = 14,
    TradePurchase = 15

}
