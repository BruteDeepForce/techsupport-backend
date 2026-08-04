using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Npgsql;
using TechSupport.Device.Contracts.Events;
using TechSupport.Trade.Contracts.Events;
using TechSupport.Trade.Data;
using TechSupport.Trade.Domain.Entities;
using TechSupport.Trade.DTO;

namespace TechSupport.Trade.Services;

public sealed class TradeService : ITradeService
{
    private readonly TradeDbContext _db;
    private readonly IBus _bus;

    private readonly ILogger<TradeService> _logger;

    public TradeService(TradeDbContext db, IBus bus, ILogger<TradeService> logger)
    {
        _db = db;
        _bus = bus;
        _logger = logger;
    }

    public async Task<TradeRecord> StartTradeAsync(Guid tenantId, Guid branchId, StartTradeRequest request, string idempotencyKey, CancellationToken cancellationToken = default)
    {
        if(request.Type == TradeType.Sale && request.Device == null && request.ExistingDeviceId == null 
            && string.IsNullOrEmpty(request.ImeiOrSerial) && request.CategoryId == null && string.IsNullOrEmpty(request.Device?.SKU))
            throw new ArgumentException("Device information is required for sale trades.", nameof(request.Device));

        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        if (branchId == Guid.Empty)
            throw new ArgumentException("BranchId is required.", nameof(branchId));

        if (!Enum.IsDefined(request.Type))
            throw new ArgumentException("Trade type is invalid.", nameof(request.Type));

        if (!Enum.IsDefined(request.PaymentMethod))
            throw new ArgumentException("Payment method is invalid.", nameof(request.PaymentMethod));

        if (request.Quantity <= 0)
            throw new ArgumentException("Quantity must be greater than 0.", nameof(request.Quantity));

        if (request.UnitPrice < 0 || request.TotalAmount <= 0)
            throw new ArgumentException("Pricing values are invalid.");

        if (request.CostPrice is < 0)
            throw new ArgumentException("CostPrice cannot be negative.", nameof(request.CostPrice));

        if (request.PaidAmount is < 0)
            throw new ArgumentException("PaidAmount cannot be negative.", nameof(request.PaidAmount));

        if (request.PaidAmount is not null && request.PaidAmount > request.TotalAmount)
            throw new ArgumentException("PaidAmount cannot be greater than TotalAmount.", nameof(request.PaidAmount));

        if (string.IsNullOrWhiteSpace(idempotencyKey))
            throw new ArgumentException("IdempotencyKey is required.", nameof(idempotencyKey));

        var normalizedIdempotencyKey = idempotencyKey.Trim();

        await EnsureUniqueIdempotencyKeyAsync(tenantId, normalizedIdempotencyKey, cancellationToken);
        if (request.Type == TradeType.Purchase)
            return await HandlePurchaseAsync(tenantId, branchId, request, normalizedIdempotencyKey, cancellationToken);

        return await HandleSellAsync(tenantId, branchId, request, normalizedIdempotencyKey, cancellationToken);
    }

    private async Task<TradeRecord> HandlePurchaseAsync(Guid tenantId, Guid branchId, StartTradeRequest request, string normalizedIdempotencyKey, CancellationToken cancellationToken)
    {
        var device = request.Device ?? throw new ArgumentException("Device payload is required.", nameof(request));

        if (string.IsNullOrWhiteSpace(device.Brand)
            || string.IsNullOrWhiteSpace(device.Model)
            || string.IsNullOrWhiteSpace(device.SerialNumber))
        {
            throw new ArgumentException("Device Brand, Model and SerialNumber are required.", nameof(request));
        }

        var existingCustomerId = request.ExistingCustomerId;
        var existingCustomerAppUserId = request.ExistingCusomerAppUserId;
        var hasExistingCustomer = existingCustomerId.HasValue && existingCustomerId.Value != Guid.Empty
            && existingCustomerAppUserId.HasValue && existingCustomerAppUserId.Value != Guid.Empty;

        if (hasExistingCustomer)
        {
            var existingCustomerIdValue = existingCustomerId!.Value;
            var existingCustomerAppUserIdValue = existingCustomerAppUserId!.Value;

            var tradeForExistingCustomer = new TradeRecord
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                CustomerId = existingCustomerIdValue,
                //!DeviceId = Guid.NewGuid(),
                CategoryId = request.CategoryId,
                Type = request.Type,
                PaymentMethod = request.PaymentMethod,
                Status = TradeStatus.Pending,
                ImeiOrSerial = request.ImeiOrSerial,
                Quantity = request.Quantity,
                UnitPrice = request.UnitPrice,
                CostPrice = request.CostPrice,
                TotalAmount = request.TotalAmount,
                PaidAmount = request.PaidAmount,
                Notes = request.Notes,
                CreatedAtUtc = DateTime.UtcNow,
                IdempotencyKey = normalizedIdempotencyKey,
                DeviceInfo = new DeviceRegisteration
                {
                    Id = Guid.NewGuid(),
                    TenantId = tenantId,
                    BranchId = branchId,
                    CustomerId = existingCustomerIdValue,
                    IdempotencyKey = normalizedIdempotencyKey,
                    Brand = device.Brand,
                    Model = device.Model,
                    SerialNumber = device.SerialNumber,
                    SKU = device.SKU,
                    ProblemDescription = device.ProblemDescription,
                    GuaranteePeriod = device.GuaranteePeriod,
                    WarrantyStartAtUtc = device.WarrantyStartAtUtc,
                    BarcodeNumber = device.BarcodeNumber,
                    CustomerName = device.CustomerName,
                    Status = "Pending",
                    IsActive = true,
                    OccurredAtUtc = DateTimeOffset.UtcNow
                }
            };

            _db.Trades.Add(tradeForExistingCustomer);
            await SaveChangesWithIdempotencyGuardAsync(cancellationToken);

            await StartDeviceCreateWithTradeAsync(
                tenantId,
                branchId,
                existingCustomerIdValue,
                existingCustomerAppUserIdValue,
                tradeForExistingCustomer.Id,
                normalizedIdempotencyKey,
                cancellationToken);

            return tradeForExistingCustomer;
        }

        if (request.Customer is null)
            throw new ArgumentException("Customer payload is required when ExistingCustomerId is not provided.", nameof(request));

        if (string.IsNullOrWhiteSpace(request.Customer.Name) || string.IsNullOrWhiteSpace(request.Customer.Email))
            throw new ArgumentException("Customer Name and Email are required.", nameof(request));

        var tradeId = Guid.NewGuid();
        var trade = new TradeRecord
        {
            Id = tradeId,
            TenantId = tenantId,
            BranchId = branchId,
            //!DeviceId = Guid.NewGuid(),
            CategoryId = request.CategoryId,
            Type = request.Type,
            PaymentMethod = request.PaymentMethod,
            Status = TradeStatus.Pending,
            ImeiOrSerial = request.ImeiOrSerial,
            Quantity = request.Quantity,
            UnitPrice = request.UnitPrice,
            CostPrice = request.CostPrice,
            TotalAmount = request.TotalAmount,
            PaidAmount = request.PaidAmount,
            Notes = request.Notes,
            CreatedAtUtc = DateTime.UtcNow,
            IdempotencyKey = normalizedIdempotencyKey,
            DeviceInfo = new DeviceRegisteration
            {
                Id = Guid.NewGuid(),
                TradeId = tradeId,
                TenantId = tenantId,
                BranchId = branchId,
                IdempotencyKey = normalizedIdempotencyKey,
                Brand = device.Brand,
                Model = device.Model,
                SerialNumber = device.SerialNumber,
                SKU = device.SKU,   
                ProblemDescription = device.ProblemDescription,
                GuaranteePeriod = device.GuaranteePeriod,
                WarrantyStartAtUtc = device.WarrantyStartAtUtc,
                BarcodeNumber = device.BarcodeNumber,
                CustomerName = device.CustomerName,
                Status = "Pending",
                IsActive = true,
                OccurredAtUtc = DateTimeOffset.UtcNow
            }
        };

        _db.Trades.Add(trade);
        await SaveChangesWithIdempotencyGuardAsync(cancellationToken);

        var customer = request.Customer;
        await _bus.Publish(new TradeCustomerProvisionRequested(
            TradeId: trade.Id,
            TenantId: trade.TenantId,
            BranchId: trade.BranchId,
            IdempotencyKey: trade.IdempotencyKey,
            Name: customer.Name.Trim(),
            Email: customer.Email.Trim(),
            PhoneNumber: customer.PhoneNumber?.Trim(),
            TemporaryPassword: customer.TemporaryPassword,
            OccurredAtUtc: DateTimeOffset.UtcNow),
            cancellationToken);

        return trade;
    }

    private async Task<TradeRecord> HandleSellAsync(Guid tenantId, Guid branchId, StartTradeRequest request, string normalizedIdempotencyKey, CancellationToken cancellationToken)
    {
        if (request.ExistingDeviceId is not Guid existingDeviceId || existingDeviceId == Guid.Empty)
            throw new ArgumentException("ExistingDeviceId is required for non-purchase trades.", nameof(request.ExistingDeviceId));

        var existingCustomerId = request.ExistingCustomerId;
        var existingCustomerAppUserId = request.ExistingCusomerAppUserId;
        _logger.LogWarning("Existing CustomerID : {customerId}", existingCustomerId);
        var hasExistingCustomer = existingCustomerId.HasValue && existingCustomerId.Value != Guid.Empty;

        if (hasExistingCustomer)
        {
            var existingCustomerIdValue = existingCustomerId!.Value;
            var device = request.Device;
            if (device is null
                || string.IsNullOrWhiteSpace(device.Brand)
                || string.IsNullOrWhiteSpace(device.Model)
                || string.IsNullOrWhiteSpace(device.SerialNumber))
            {
                throw new ArgumentException("Device Brand, Model and SerialNumber are required for non-purchase trades.", nameof(request));
            }

            var brand = device.Brand.Trim();
            var model = device.Model.Trim();
            var serialNumber = device.SerialNumber.Trim();
            var tradeId = Guid.NewGuid();

            var trade = new TradeRecord
            {
                Id = tradeId,
                TenantId = tenantId,
                BranchId = branchId,
                CustomerId = existingCustomerIdValue,
                DeviceId = existingDeviceId,
                DeviceInfo = new DeviceRegisteration
                {
                    Id = Guid.NewGuid(),
                    TradeId = tradeId,
                    TenantId = tenantId,
                    BranchId = branchId,
                    CustomerId = existingCustomerIdValue,
                    IdempotencyKey = normalizedIdempotencyKey,
                    Brand = brand,
                    Model = model,
                    SerialNumber = serialNumber,
                    ProblemDescription = device.ProblemDescription,
                    GuaranteePeriod = device.GuaranteePeriod,
                    WarrantyStartAtUtc = device.WarrantyStartAtUtc,
                    BarcodeNumber = device.BarcodeNumber?.Trim(),
                    CustomerName = request.ExistingCustomerName?.Trim(),
                    Status = "Pending",
                    IsActive = true,
                    OccurredAtUtc = DateTimeOffset.UtcNow
                },
                Type = request.Type,
                PaymentMethod = request.PaymentMethod,
                Status = TradeStatus.Pending,
                ImeiOrSerial = request.ImeiOrSerial,
                Quantity = request.Quantity,
                UnitPrice = request.UnitPrice,
                CostPrice = request.CostPrice,
                TotalAmount = request.TotalAmount,
                PaidAmount = request.PaidAmount,
                Notes = request.Notes,
                CreatedAtUtc = DateTime.UtcNow,
                IdempotencyKey = normalizedIdempotencyKey
            };

            _db.Trades.Add(trade);
            await SaveChangesWithIdempotencyGuardAsync(cancellationToken);

            _logger.LogWarning("Publishing DeviceCustomerMapping for existing device {DeviceId} and customer {CustomerId} in trade {TradeId}", existingDeviceId, existingCustomerIdValue, trade.Id);

            await _bus.Publish(new DeviceCustomerMapping
            {
                TradeId = trade.Id,
                DeviceId = existingDeviceId,
                TenantId = tenantId,
                BranchId = branchId,
                CustomerId = existingCustomerIdValue,
                AppUserId = existingCustomerAppUserId,
                Status = "Selled",
                CustomerName = request.ExistingCustomerName?.Trim(),
                ProblemDescription = null,
                Brand = brand,
                Model = model,
                SerialNumber = serialNumber,
                IdempotencyKey = normalizedIdempotencyKey,
                IsActive = true,
                UpdatedAtUtc = DateTimeOffset.UtcNow,
                CreatedAtUtc = DateTimeOffset.UtcNow,
                GuaranteePeriod = device.GuaranteePeriod,
                WarrantyStartAtUtc = device.WarrantyStartAtUtc,
                WarrantyEndAtUtc = device.WarrantyStartAtUtc.HasValue && device.GuaranteePeriod.HasValue
                    ? device.WarrantyStartAtUtc.Value.AddMonths(device.GuaranteePeriod.Value)
                    : (DateTimeOffset?)null,
                BarcodeNumber = device.BarcodeNumber?.Trim()
            }, cancellationToken);

            return trade;
        }
        //! müşteri manuel giriş yapıldıysa
        var customer = request.Customer;
        if (customer is null
            || string.IsNullOrWhiteSpace(customer.Name)
            || string.IsNullOrWhiteSpace(customer.Email)
            || string.IsNullOrWhiteSpace(customer.TemporaryPassword)
            || string.IsNullOrWhiteSpace(customer.PhoneNumber))
        {
            throw new ArgumentException("Customer Name, Email, PhoneNumber, and TemporaryPassword are required when ExistingCustomerId is not provided.", nameof(request));
        }
        var newCustomerTradeId = Guid.NewGuid();

        var newCustomerTrade = new TradeRecord
        {
            Id = newCustomerTradeId,
            TenantId = tenantId,
            BranchId = branchId,
            DeviceId = existingDeviceId,
            DeviceInfo = new DeviceRegisteration()
            {
                Id = Guid.NewGuid(),
                TradeId = newCustomerTradeId,
                TenantId = tenantId,
                BranchId = branchId,
                IdempotencyKey = normalizedIdempotencyKey,
                Brand = request.Device?.Brand?.Trim() ?? string.Empty,
                Model = request.Device?.Model?.Trim() ?? string.Empty,
                SerialNumber = request.Device?.SerialNumber?.Trim() ?? string.Empty,
                ProblemDescription = request.Device?.ProblemDescription,
                GuaranteePeriod = request.Device?.GuaranteePeriod,
                WarrantyStartAtUtc = request.Device?.WarrantyStartAtUtc,
                BarcodeNumber = request.Device?.BarcodeNumber?.Trim(),
                CustomerName = customer.Name.Trim(),
                Status = "Pending",
                IsActive = true,
                OccurredAtUtc = DateTimeOffset.UtcNow
            },
            Type = request.Type,
            PaymentMethod = request.PaymentMethod,
            Status = TradeStatus.Pending,
            ImeiOrSerial = request.ImeiOrSerial,
            Quantity = request.Quantity,
            UnitPrice = request.UnitPrice,
            CostPrice = request.CostPrice,
            TotalAmount = request.TotalAmount,
            PaidAmount = request.PaidAmount,
            Notes = request.Notes,
            CreatedAtUtc = DateTime.UtcNow,
            IdempotencyKey = normalizedIdempotencyKey
        };

        _db.Trades.Add(newCustomerTrade);
        await SaveChangesWithIdempotencyGuardAsync(cancellationToken);

        await _bus.Publish(new TradeCustomerProvisionRequested(
            TradeId: newCustomerTrade.Id,
            TenantId: newCustomerTrade.TenantId,
            BranchId: newCustomerTrade.BranchId,
            IdempotencyKey: newCustomerTrade.IdempotencyKey,
            Name: customer.Name.Trim(),
            Email: customer.Email.Trim(),
            PhoneNumber: customer.PhoneNumber.Trim(),
            TemporaryPassword: customer.TemporaryPassword.Trim(),
            OccurredAtUtc: DateTimeOffset.UtcNow),
            cancellationToken);

        return newCustomerTrade;
    }

    public async Task<bool> StartDeviceCreateWithTradeAsync(Guid tenantId, Guid branchId, Guid customerId,
    Guid customerAppUserId, Guid TradeId, string idempotencyKey, CancellationToken cancellationToken = default)
    {
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));
        if (branchId == Guid.Empty)
            throw new ArgumentException("BranchId is required.", nameof(branchId));
        if (customerId == Guid.Empty)
            throw new ArgumentException("CustomerId is required.", nameof(customerId));
        if (customerAppUserId == Guid.Empty)
            throw new ArgumentException("CustomerAppUserId is required.", nameof(customerAppUserId));
        if (TradeId == Guid.Empty)
            throw new ArgumentException("TradeId is required.", nameof(TradeId));
        if (string.IsNullOrWhiteSpace(idempotencyKey))
            throw new ArgumentException("IdempotencyKey is required.", nameof(idempotencyKey));

        var normalizedIdempotencyKey = idempotencyKey.Trim();

        var trade = await _db.Trades.Include(x => x.DeviceInfo).FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == TradeId && x.Status == TradeStatus.Pending
        && x.IdempotencyKey == normalizedIdempotencyKey, cancellationToken);
        if (trade == null)
            throw new KeyNotFoundException("Trade not found or already processed.");
        //! deviceid zaten var ise yeni device kaydı gerekmez. bu yüzden direkt burada Maplemeye trigger atıyoruz. 
        //! yoksa yeni device kaydı yapılır ve sonra mapleme yapılır. bu sayede iki durumda da mapleme triggerlanmış olur.
        if (trade.DeviceId.HasValue)
        {
            var mappingBrand = trade.DeviceInfo?.Brand?.Trim() ?? string.Empty;
            var mappingModel = trade.DeviceInfo?.Model?.Trim() ?? string.Empty;
            var mappingSerialNumber = trade.DeviceInfo?.SerialNumber?.Trim() ?? string.Empty;

            await _bus.Publish(new DeviceCustomerMapping
            {
                DeviceId = trade.DeviceId.Value,
                TenantId = tenantId,
                BranchId = branchId,
                CustomerId = customerId,
                AppUserId = customerAppUserId,
                Status = "Selled",
                CustomerName = trade.DeviceInfo?.CustomerName,
                ProblemDescription = trade.DeviceInfo?.ProblemDescription,
                Brand = mappingBrand,
                Model = mappingModel,
                SerialNumber = mappingSerialNumber,
                IsActive = true,
                UpdatedAtUtc = DateTimeOffset.UtcNow,
                CreatedAtUtc = DateTimeOffset.UtcNow,
                GuaranteePeriod = trade.DeviceInfo?.GuaranteePeriod,
                WarrantyStartAtUtc = trade.DeviceInfo?.WarrantyStartAtUtc,
                WarrantyEndAtUtc = trade.DeviceInfo?.WarrantyStartAtUtc.HasValue == true && trade.DeviceInfo.GuaranteePeriod.HasValue == true
                    ? trade.DeviceInfo.WarrantyStartAtUtc.Value.AddMonths(trade.DeviceInfo.GuaranteePeriod.Value)
                    : (DateTimeOffset?)null,
                BarcodeNumber = trade.DeviceInfo?.BarcodeNumber,
                TradeId = trade.Id,
                IdempotencyKey = normalizedIdempotencyKey
            }, cancellationToken);

            return true;
        }

        var deviceInfo = trade.DeviceInfo ?? throw new InvalidOperationException("Trade device payload not found.");
        var brand = deviceInfo.Brand?.Trim();
        var model = deviceInfo.Model?.Trim();
        var serialNumber = deviceInfo.SerialNumber?.Trim();

        if (string.IsNullOrWhiteSpace(brand)
            || string.IsNullOrWhiteSpace(model)
            || string.IsNullOrWhiteSpace(serialNumber))
        {
            throw new InvalidOperationException("Trade device payload is incomplete. Brand, Model and SerialNumber are required.");
        }


        await _bus.Publish(new TradeDeviceRegistrationRequested( //! mal gibi satın aldığımız ürünü müşteriye geri mapliyoruz :)
            TradeId: trade.Id,
            TenantId: tenantId,
            BranchId: branchId,
            CustomerId: customerId,
            AppUserId: customerAppUserId,
            IdempotencyKey: normalizedIdempotencyKey,
            Brand: brand,
            Model: model,
            SerialNumber: serialNumber,
            ProblemDescription: deviceInfo.ProblemDescription?.Trim(),
            GuaranteePeriod: deviceInfo.GuaranteePeriod,
            WarrantyStartAtUtc: deviceInfo.WarrantyStartAtUtc,
            BarcodeNumber: deviceInfo.BarcodeNumber?.Trim(),
            CustomerName: deviceInfo.CustomerName?.Trim(),
            Status: "Pending",
            OccurredAtUtc: DateTimeOffset.UtcNow),
            cancellationToken);

        return true;
    }

    public async Task<TradeRecord?> GetByIdAsync(Guid tenantId, Guid tradeId, CancellationToken cancellationToken = default)
    {
        return await _db.Trades
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == tradeId, cancellationToken);
    }

    public async Task<bool> AccountModuleInsertAfterMappingAsync(Guid tenantId, Guid branchId, Guid customerId, Guid tradeId, string idempotencyKey, CancellationToken cancellationToken = default)
    {
        var normalizedIdempotencyKey = idempotencyKey.Trim();

        var trade = await _db.Trades.FirstOrDefaultAsync(
            x => x.TenantId == tenantId && x.Id == tradeId,
            cancellationToken);

        if (trade == null)
            throw new KeyNotFoundException("Trade not found.");

        if (!string.Equals(trade.IdempotencyKey, normalizedIdempotencyKey, StringComparison.Ordinal))
            throw new ArgumentException("Trade idempotency key mismatch.", nameof(idempotencyKey));

        if (branchId != Guid.Empty && trade.BranchId != branchId)
            throw new ArgumentException("Trade branch mismatch.", nameof(branchId));

        if (trade.Status == TradeStatus.Completed)
            return true;

        if (trade.Status == TradeStatus.Failed)
            return false;

        if (trade.Status != TradeStatus.Pending)
            throw new InvalidOperationException("Trade is not in a processable status.");

        if (!trade.CustomerId.HasValue || trade.CustomerId.Value == Guid.Empty)
        {
            if (customerId == Guid.Empty)
                throw new InvalidOperationException("Trade customer is required for accounting pipeline.");

            trade.CustomerId = customerId;
            await _db.SaveChangesAsync(cancellationToken);
        }
        else if (trade.CustomerId.Value != customerId)
        {
            throw new InvalidOperationException("Trade customer mismatch for accounting pipeline.");
        }
        _logger.LogInformation("Publishing TradeAccountModuleInserted event for TradeId: {TradeId}, CustomerId: {CustomerId}, TenantId: {TenantId}", trade.Id, customerId, tenantId);

        await _bus.Publish(new TradeAccountModuleInserted(
            TradeId: trade.Id,
            TenantId: tenantId,
            BranchId: trade.BranchId,
            CustomerId: trade.CustomerId.Value,
            IdempotencyKey: normalizedIdempotencyKey,
            OccurredAtUtc: DateTimeOffset.UtcNow,
            Quantity: trade.Quantity,
            UnitPrice: trade.UnitPrice,
            CostPrice: trade.CostPrice,
            TotalAmount: trade.TotalAmount,
            PaidAmount: trade.PaidAmount,
            IsPurchase: trade.Type == TradeType.Purchase,
            PaymentMethod: trade.PaymentMethod switch
            {
                TradePaymentMethod.Cash => PaymentMethod.Cash,
                TradePaymentMethod.Card => PaymentMethod.Card,
                TradePaymentMethod.Transfer => PaymentMethod.Transfer,
                _ => throw new InvalidOperationException("Unsupported payment method.")
            }),
            cancellationToken);

        return true;
    }

    public async Task<TradeServiceResult<List<TradeResponse>>> GetTradesAsync(Guid tenantId, int page = 1, int pageSize = 10, CancellationToken cancellationToken = default)
    {
        //! redis kurgulanacak....
        if (tenantId == Guid.Empty)
            throw new ArgumentException("TenantId is required.", nameof(tenantId));

        var trades = await _db.Trades
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new TradeResponse
            {
                TradeId = x.Id,
                CustomerId = x.CustomerId ?? Guid.Empty,
                DeviceId = x.DeviceId ?? Guid.Empty,
                Status = x.Status.ToString(),
                PaymentMethod = x.PaymentMethod.ToString(),
                CustomerName = x.DeviceInfo!.CustomerName ?? string.Empty,
                DeviceName = (x.DeviceInfo!.Brand ?? string.Empty) + " " + (x.DeviceInfo!.Model ?? string.Empty),
                Type = x.Type.ToString(),
                TotalAmount = x.TotalAmount,
                CreatedAt = x.CreatedAtUtc,
                Page = page,
                PageSize = pageSize,
                ExistingCount = _db.Trades.Count(t => t.TenantId == tenantId) - ((page - 1) * pageSize)
            })
            .ToListAsync(cancellationToken);

        if (trades == null || !trades.Any())
            return TradeServiceResult<List<TradeResponse>>.Failure("Trade not found.");

        return TradeServiceResult<List<TradeResponse>>.SuccessResult(trades);
    }

    private async Task EnsureUniqueIdempotencyKeyAsync(Guid tenantId, string normalizedIdempotencyKey, CancellationToken cancellationToken)
    {
        var isExistKey = await _db.Trades.AnyAsync(key =>
            key.TenantId == tenantId && key.IdempotencyKey == normalizedIdempotencyKey,
            cancellationToken);

        if (isExistKey)
            throw new ArgumentException("Duplicate request with the same IdempotencyKey already exists.", "idempotencyKey");
    }

    private async Task SaveChangesWithIdempotencyGuardAsync(CancellationToken cancellationToken)
    {
        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException ex) when (IsIdempotencyUniqueViolation(ex))
        {
            throw new ArgumentException("Duplicate request with the same IdempotencyKey already exists.", "idempotencyKey");
        }
    }

    private static bool IsIdempotencyUniqueViolation(DbUpdateException ex)
    {
        if (ex.InnerException is PostgresException pg && pg.SqlState == PostgresErrorCodes.UniqueViolation)
        {
            return string.Equals(pg.ConstraintName, "IX_Trades_TenantId_IdempotencyKey", StringComparison.Ordinal)
                || (pg.Detail?.Contains("IdempotencyKey", StringComparison.OrdinalIgnoreCase) ?? false);
        }

        return false;
    }
}
