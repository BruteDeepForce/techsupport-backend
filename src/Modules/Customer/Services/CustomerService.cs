using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.Customer.Data;
using TechSupport.Customer.Contracts.Events;
using TechSupport.Customer.Domain.Entities;
using TechSupport.Identity.Contracts.Events;
using MassTransit.Initializers;

namespace TechSupport.Customer.Services
{
    public interface ICustomerService
    {
        Task<bool> GetCustomerExistsAsync(Guid customerId);
        Task<TechSupport.Customer.Domain.Entities.Customer> CreateCustomerAsync(Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, CancellationToken ct);
        Task<bool> DeleteCustomerAsync(Guid customerId, CancellationToken ct);
        Task<bool> AssignDeviceToCustomerAsync(Guid tenantId, Guid? branchId, Guid customerId, Guid deviceId, 
        string? deviceSerialNumber, string? barcodeNumber, string? problemDescription, 
        string? model, string status, CancellationToken ct,
        string? brand = null, bool isActive = true, int? guaranteePeriod = null,
        DateTimeOffset? warrantyStartAtUtc = null, DateTimeOffset? warrantyEndAtUtc = null);
        Task<TechSupport.Customer.Domain.Entities.Customer?> GetByIdAsync(Guid tenantId, Guid customerId, CancellationToken ct);
        Task<IReadOnlyList<TechSupport.Customer.Domain.Entities.Customer>> ListAsync(Guid tenantId, CancellationToken ct);
        Task<CustomerProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, string temporaryPassword, CancellationToken ct);
        Task<CustomerProvisionRequest?> GetProvisioningStatusAsync(Guid correlationId, CancellationToken ct);
        Task CompleteProvisioningAsync(Guid correlationId, Guid appUserId, Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, CancellationToken ct);
        Task FailProvisioningAsync(Guid correlationId, string reason, CancellationToken ct);
    }

    public class CustomerService : ICustomerService
    {
        private readonly CustomerDbContext _db;
        private readonly IBus _bus;

        public CustomerService(CustomerDbContext db, IBus bus)
        {
            _db = db;
            _bus = bus;
        }

        public async Task<bool> AssignDeviceToCustomerAsync(Guid tenantId, Guid? branchId, Guid customerId, Guid deviceId, 
        string? deviceSerialNumber, string? barcodeNumber, string? problemDescription,
        string? model, string status, CancellationToken ct,
        string? brand = null, bool isActive = true, int? guaranteePeriod = null,
        DateTimeOffset? warrantyStartAtUtc = null, DateTimeOffset? warrantyEndAtUtc = null)
        {
            var customer = await _db.Customers.FirstOrDefaultAsync(x => x.Id == customerId && x.TenantId == tenantId, ct);
            if (customer is null) return false;

            var existing = await _db.CustomerDevices
                .FirstOrDefaultAsync(x => x.CustomerId == customerId && x.DeviceId == deviceId, ct);

            if (existing is null)
            {
                existing = new CustomerDevice
                {
                    Id = Guid.NewGuid(),
                    TenantId = customer.TenantId,
                    BranchId = branchId ?? customer.BranchId,
                    CustomerId = customerId,
                    DeviceId = deviceId,
                    CreatedAtUtc = DateTime.UtcNow
                };

                await _db.CustomerDevices.AddAsync(existing, ct);
            }

            existing.TenantId = customer.TenantId;
            existing.BranchId = branchId ?? customer.BranchId;
            existing.Brand = brand?.Trim();
            existing.Model = model?.Trim();
            existing.SerialNumber = deviceSerialNumber?.Trim();
            existing.BarcodeNumber = barcodeNumber?.Trim();
            existing.ProblemDescription = problemDescription?.Trim();
            existing.Status = string.IsNullOrWhiteSpace(status) ? null : status.Trim();
            existing.IsActive = isActive;
            existing.GuaranteePeriod = guaranteePeriod;
            existing.WarrantyStartAtUtc = warrantyStartAtUtc;
            existing.WarrantyEndAtUtc = warrantyEndAtUtc;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            if (!isActive && existing.DeletedAtUtc is null)
            {
                existing.DeletedAtUtc = DateTime.UtcNow;
            }
            else if (isActive)
            {
                existing.DeletedAtUtc = null;
            }

            await _db.SaveChangesAsync(ct);
            return true;
        }
        //! kaldırıldı kullanılmıyor StartProvisioningAsync metodu içerisinde müşteri oluşturuluyor.
        public async Task<TechSupport.Customer.Domain.Entities.Customer> CreateCustomerAsync(Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, CancellationToken ct)
        {
            var exists = await _db.Customers.AnyAsync(x => x.TenantId == tenantId && x.Email == email, ct);
            if (exists) throw new InvalidOperationException("Customer already exists for tenant");

            var customer = new TechSupport.Customer.Domain.Entities.Customer
            {
                Id = Guid.NewGuid(),
                TenantId = tenantId,
                BranchId = branchId,
                Name = name.Trim(),
                Email = email.Trim(),
                PhoneNumber = phoneNumber?.Trim() ?? string.Empty
            };

            _db.Customers.Add(customer);
            await _db.SaveChangesAsync(ct);
            return customer;
        }

        public async Task<bool> DeleteCustomerAsync(Guid customerId, CancellationToken ct)
        {
            var customer = await _db.Customers.FirstOrDefaultAsync(x => x.Id == customerId, ct);
            if (customer is null) return false;

            _db.Customers.Remove(customer);
            await _db.SaveChangesAsync(ct);
            return true;
        }

        public Task<bool> GetCustomerExistsAsync(Guid customerId)
        {
            return _db.Customers.AnyAsync(x => x.Id == customerId);
        }

        public Task<TechSupport.Customer.Domain.Entities.Customer?> GetByIdAsync(Guid tenantId, Guid customerId, CancellationToken ct)
        {
            return _db.Customers
                .AsNoTracking()
                .Include(x => x.Devices)
                .FirstOrDefaultAsync(x => x.TenantId == tenantId && x.Id == customerId, ct);
        }

        public async Task<IReadOnlyList<TechSupport.Customer.Domain.Entities.Customer>> ListAsync(Guid tenantId, CancellationToken ct)
        {
            return await _db.Customers
                .AsNoTracking()
                .Where(x => x.TenantId == tenantId)
                .OrderBy(x => x.Name)
                .ToListAsync(ct);
        }

        public async Task<CustomerProvisionRequest> StartProvisioningAsync(Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, string temporaryPassword, CancellationToken ct)
        {
            //varsa bu müşteri start yapmıyoruz. Aynı email ve telefon numarasıyla müşteri varsa yeni bir provision request oluşturulmaz, var olan request döndürülür veya hata verilir. Bu sayede aynı müşteri için birden fazla provisioning süreci başlamasının önüne geçilir.
            var correlationId = Guid.NewGuid();

            var isExisting = await _db.Customers.Where(x => x.TenantId == tenantId && x.Email == email && x.PhoneNumber == phoneNumber)
            .Select(x => x.Email)
            .Union(_db.CustomerProvisionRequests.Where(x => x.TenantId == tenantId && x.Email == email && x.PhoneNumber == phoneNumber && x.Status != ProvisioningStatus.Failed)
            .Select(x => x.Email))
            .AnyAsync(ct);

            if (isExisting)
            {
                return new CustomerProvisionRequest
                {
                    Id = Guid.NewGuid(),
                    CorrelationId = correlationId,
                    TenantId = tenantId,
                    BranchId = branchId,
                    Name = name.Trim(),
                    Email = email.Trim(),
                    PhoneNumber = phoneNumber?.Trim() ?? string.Empty,
                    Status = ProvisioningStatus.Failed,
                    FailureReason = "Customer with the same email and phone number already exists.",
                    CreatedAtUtc = DateTimeOffset.UtcNow,
                    CompletedAtUtc = DateTimeOffset.UtcNow
                };
            }

            var request = new CustomerProvisionRequest
            {
                Id = Guid.NewGuid(),
                CorrelationId = correlationId,
                TenantId = tenantId,
                BranchId = branchId,
                Name = name.Trim(),
                Email = email.Trim(),
                PhoneNumber = phoneNumber?.Trim() ?? string.Empty,
                Status = ProvisioningStatus.Pending,
                CreatedAtUtc = DateTimeOffset.UtcNow
            };

            await _db.CustomerProvisionRequests.AddAsync(request, ct);
            await _db.SaveChangesAsync(ct);

            await _bus.Publish(new CustomerAccountProvisionRequested(
                request.CorrelationId,
                request.TenantId,
                request.BranchId,
                request.Name,
                request.Email,
                request.PhoneNumber,
                temporaryPassword), ct);

            return request;
        }

        public Task<CustomerProvisionRequest?> GetProvisioningStatusAsync(Guid correlationId, CancellationToken ct)
        {
            return _db.CustomerProvisionRequests.AsNoTracking().FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
        }

        public async Task CompleteProvisioningAsync(Guid correlationId, Guid appUserId, Guid tenantId, Guid? branchId, string name, string email, string? phoneNumber, CancellationToken ct)
        {
            //cusotmerid return edilmeli....
            var request = await _db.CustomerProvisionRequests.FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
            if (request is null || request.Status == ProvisioningStatus.Completed)
            {
                return;
            }

            var existingCustomer = await _db.Customers.FirstOrDefaultAsync(x => x.AppUserId == appUserId || (x.TenantId == tenantId && x.Email == email), ct);
            if (existingCustomer is null)
            {
                existingCustomer = new TechSupport.Customer.Domain.Entities.Customer
                {
                    Id = Guid.NewGuid(),
                    AppUserId = appUserId,
                    TenantId = tenantId,
                    BranchId = branchId,
                    Name = name,
                    Email = email,
                    PhoneNumber = phoneNumber ?? string.Empty
                };

                await _db.Customers.AddAsync(existingCustomer, ct);
            }
            else
            {
                existingCustomer.AppUserId = appUserId;
                existingCustomer.Name = name;
                existingCustomer.Email = email;
                existingCustomer.PhoneNumber = phoneNumber ?? string.Empty;
                existingCustomer.BranchId = branchId;
            }

            request.Status = ProvisioningStatus.Completed;
            request.AppUserId = appUserId;
            request.CustomerId = existingCustomer.Id;
            request.CompletedAtUtc = DateTimeOffset.UtcNow;
            request.FailureReason = null;

            await _db.SaveChangesAsync(ct);

            //customer create eventini report ve operation modülleri dinliyor.
            await _bus.Publish(new CustomerCreated(existingCustomer.Id, existingCustomer.AppUserId, existingCustomer.TenantId, existingCustomer.BranchId, existingCustomer.Name, existingCustomer.Email, DateTimeOffset.UtcNow), ct);
            //await _bus.Publish(new CustomerIdentityLinked(existingCustomer.Id, appUserId, correlationId, DateTimeOffset.UtcNow), ct);
        }

        public async Task FailProvisioningAsync(Guid correlationId, string reason, CancellationToken ct)
        {
            var request = await _db.CustomerProvisionRequests.FirstOrDefaultAsync(x => x.CorrelationId == correlationId, ct);
            if (request is null || request.Status == ProvisioningStatus.Completed)
            {
                return;
            }

            request.Status = ProvisioningStatus.Failed;
            request.FailureReason = reason;
            request.CompletedAtUtc = DateTimeOffset.UtcNow;

            await _db.SaveChangesAsync(ct);
        }
    }
}
