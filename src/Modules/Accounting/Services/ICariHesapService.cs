using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using TechSupport.Accounting.DTO;
using TechSupport.Accounting.Domain.Entities;

namespace TechSupport.Accounting.Services;

public interface ICariHesapService
{
    // Movement (Hareket) operations
    Task<CariHesapHareketi?> GetHareketByIdAsync(Guid tenantId, Guid hareketId, CancellationToken ct = default);
    // Per-account movement listing removed. Use GetEkstreAsync for statement + movements.
    Task<IReadOnlyList<CariHesapHareketi>> ListHareketlerForTenantAsync(Guid tenantId, int page = 1, int pageSize = 50, CancellationToken ct = default);
    Task<CariHesapHareketi> CreateHareketAsync(Guid tenantId, Guid? branchId, CreateCariHesapHareketiRequest request, string? createdBy = null, CancellationToken ct = default);
    
    // Balance operations (Bakiye = Sum(Borc) - Sum(Alacak))
    Task<CariHesapBakiyeResponse> GetBakiyeAsync(Guid tenantId, Guid accountId, Guid customerId, CancellationToken ct = default);
    
    // Account statement (Ekstre) operations
    Task<CariHesapEkstreResponse> GetEkstreAsync(Guid tenantId, CariHesapEkstreRequest request, CancellationToken ct = default);
    
    // List all Cari Hesap accounts with balances
    Task<IReadOnlyList<CariHesapListItemResponse>> ListCariHesaplarAsync(Guid tenantId, int page = 1, int pageSize = 20, CancellationToken ct = default);
}
