# Accounting Module Implementation Plan (Updated with Cari Hesap)

## 1. Architecture Analysis

### 1.1 Current System Overview
The techsupport-backend follows a modular, multi-tenant architecture with the following characteristics:

- **Framework**: ASP.NET Core 9.0 with Entity Framework Core 9.0
- **Database**: PostgreSQL with separate schemas per module
- **Authentication**: JWT Bearer tokens with role-based authorization
- **Messaging**: MassTransit for event-driven communication

### 1.2 Existing Modules
| Module | Purpose | Schema |
|--------|---------|--------|
| Identity | Authentication, Tenant/Branch management | identity |
| Customer | Customer management | customers |
| Device | Device registry and tracking | devices |
| Operation | Tickets, Work Orders | operations |
| Technician | Technician profiles | technicians |
| Stock | Inventory management | stock |
| Reports | Analytics and reporting | reports |
| AI | AI orchestration | ai |

---

## 2. Entity Pattern Analysis

### 2.1 Standard Entity Structure
All entities follow this pattern:
- **Id**: `Guid` primary key
- **TenantId**: `Guid` - Required for ALL tenant-scoped entities
- **BranchId**: `Guid?` - Optional branch-level granularity
- **Auditing**: `CreatedAtUtc`, `UpdatedAtUtc` timestamps
- **Navigation Properties**: Defined in DbContext with proper relationships

### 2.2 Entity Example (Customer)
```csharp
public sealed class Customer
{
    public Guid Id { get; set; }
    public Guid? AppUserId { get; set; }
    public Guid TenantId { get; set; }        // Required
    public Guid? BranchId { get; set; }       // Optional
    public string Name { get; set; }
    public string Email { get; set; }
    public string PhoneNumber { get; set; }
    public ICollection<CustomerDevice> Devices { get; set; }
}
```

### 2.3 DbContext Pattern
- Separate `DbContext` per module
- Schema definition in `OnModelCreating`
- Composite indexes on `(TenantId, unique_field)`
- Foreign key relationships with cascade rules

---

## 3. Tenant Isolation Pattern

### 3.1 Current Implementation
Tenant isolation is enforced at the **application level** (not database level):

```csharp
private Guid? GetTenantIdFromClaims()
{
    var claim = User.FindFirst("tenant_id");
    return claim != null ? Guid.Parse(claim.Value) : null;
}
```

### 3.2 Service Layer Pattern
Every service method explicitly accepts `tenantId` as a parameter:
```csharp
Task<IReadOnlyList<Customer>> ListAsync(Guid tenantId, CancellationToken ct);
```

### 3.3 Key Pattern
```csharp
// All queries MUST include TenantId filter
await _db.Customers.Where(x => x.TenantId == tenantId).ToListAsync(ct);
```

---

## 4. Cari Hesap (Account Receivable) System Design

### 4.1 Business Requirements

Based on user requirements:
- Customer transaction: 300 TL
- Customer pays: 100 TL
- Remaining 200 TL should show as "Cari Hesap" (receivable/debt)

### 4.2 Entity Design

```mermaid
erDiagram
    Account ||--o{ Invoice : has
    Account ||--o{ Payment : has
    Account ||--o{ CariHesapHareketi : has
    Invoice ||--o{ InvoiceLineItem : has
    Invoice ||--o{ Payment : partial
    Invoice ||--o{ CariHesapHareketi : generates
    Payment ||--o{ CariHesapHareketi : generates
    Customer ||--o{ Account : has
    
    Account {
        guid Id
        guid TenantId
        guid BranchId
        guid CustomerId
        string AccountNumber
        decimal Balance
        AccountStatus Status
        AccountType Type
        datetime CreatedAtUtc
    }
    
    CariHesapHareketi {
        guid Id
        guid TenantId
        guid BranchId
        guid AccountId
        guid? InvoiceId
        guid? PaymentId
        string HareketType
        datetime HareketTarihi
        decimal Borc
        decimal Alacak
        decimal Bakiye
        string Aciklama
    }
    
    Invoice {
        guid Id
        guid TenantId
        guid BranchId
        guid AccountId
        guid? OperationId
        string InvoiceNumber
        datetime InvoiceDate
        datetime DueDate
        InvoiceStatus Status
        decimal SubTotal
        decimal TaxAmount
        decimal Total
    }
    
    InvoiceLineItem {
        guid Id
        guid TenantId
        guid InvoiceId
        guid? StockItemId
        string Description
        int Quantity
        decimal UnitPrice
        decimal LineTotal
    }
    
    Payment {
        guid Id
        guid TenantId
        guid BranchId
        guid AccountId
        guid? InvoiceId
        string PaymentNumber
        datetime PaymentDate
        decimal Amount
        PaymentMethod Method
        PaymentStatus Status
    }
```

### 4.3 Entity Definitions

#### Account (Extended with CustomerId for Cari Hesap)
```csharp
public class Account
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    // Cari Hesap fields (customer receivable tracking)
    public Guid? CustomerId { get; set; }        // Link to customer for Cari Hesap
    public Customer? Customer { get; set; }
    
    // General Accounting fields
    public string AccountNumber { get; set; }    // Unique per tenant
    public string Name { get; set; }
    public string? Description { get; set; }
    
    public AccountType Type { get; set; }         // Revenue, Expense, Cash, Bank, CariHesap
    public AccountStatus Status { get; set; }    // Active, Suspended, Closed
    
    public decimal Balance { get; set; }         // Current balance (for Cari: total receivable)
    public decimal CreditLimit { get; set; }     // Credit limit for customer accounts
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    
    // Relationships
    public ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

public enum AccountType
{
    Revenue,      // Gelir hesabı
    Expense,     // Gider hesabı
    Budget,      // Bütçe hesabı
    Cash,        // Kasa hesabı
    Bank,        // Banka hesabı
    CariHesap    // MÜSTAKİL CARİ HESAP (new)
}

public enum AccountStatus
{
    Active,
    Suspended,
    Closed
}
```

#### CariHesapHareketi (Ledger Entry)
```csharp
public class CariHesapHareketi
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid AccountId { get; set; }              // Link to Account (Cari Hesap)
    public Account? Account { get; set; }
    
    public Guid? InvoiceId { get; set; }             // Link to Invoice (optional)
    public Invoice? Invoice { get; set; }
    
    public Guid? PaymentId { get; set; }              // Link to Payment (optional)
    public Payment? Payment { get; set; }
    
    public CariHesapHareketType HareketType { get; set; }  // Type of entry
    public DateTimeOffset HareketTarihi { get; set; }      // Transaction date
    
    public decimal Borc { get; set; }                  // Debit amount (borç)
    public decimal Alacak { get; set; }               // Credit amount (alacak)
    public decimal Bakiye { get; set; }                // Running balance after this entry
    
    public string? Aciklama { get; set; }             // Description/notes
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public string? CreatedBy { get; set; }
}

public enum CariHesapHareketType
{
    Fatura,           // Invoice created - adds to debt (Borc)
    Odeme,            // Payment received - reduces debt (Alacak)
    OdemeIade,        // Payment refund - adds to debt
    Tahsilat,         // Collection - reduces debt
    EksiyeAlan,       // Credit note - reduces debt
    Virman,           // Transfer between accounts
    Duzeltme          // Correction entry
}
```

#### Invoice
```csharp
public class Invoice
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid AccountId { get; set; }              // Account (Cari Hesap) for this invoice
    public Account? Account { get; set; }
    
    public Guid? OperationId { get; set; }           // Link to work order
    
    public string InvoiceNumber { get; set; }        // Unique per tenant
    public InvoiceStatus Status { get; set; }
    public InvoiceType Type { get; set; }
    
    public DateTimeOffset IssueDate { get; set; }
    public DateTimeOffset DueDate { get; set; }
    public DateTimeOffset? PaidDate { get; set; }
    
    public decimal Subtotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    
    public string? Notes { get; set; }
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    
    public ICollection<InvoiceLineItem> LineItems { get; set; } = new List<InvoiceLineItem>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

public enum InvoiceStatus
{
    Draft,
    Issued,
    Paid,
    Overdue,
    Cancelled,
    PartiallyPaid
}

public enum InvoiceType
{
    Standard,
    Credit,
    ProForma
}
```

#### Payment
```csharp
public class Payment
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }
    
    public Guid AccountId { get; set; }              // Account (Cari Hesap)
    public Account? Account { get; set; }
    
    public Guid? InvoiceId { get; set; }             // Optional: specific invoice payment
    public Invoice? Invoice { get; set; }
    
    public string PaymentNumber { get; set; }         // Unique per tenant
    public PaymentMethod Method { get; set; }
    public PaymentStatus Status { get; set; }
    
    public decimal Amount { get; set; }
    public decimal FeeAmount { get; set; }
    public decimal NetAmount { get; set; }
    
    public string? ReferenceNumber { get; set; }
    public string? Notes { get; set; }
    
    public DateTimeOffset PaymentDate { get; set; }
    public DateTimeOffset? ProcessedAtUtc { get; set; }
    
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }
    
    public ICollection<CariHesapHareketi> CariHesapHareketleri { get; set; } = new List<CariHesapHareketi>();
}

public enum PaymentMethod
{
    Cash,
    CreditCard,
    DebitCard,
    BankTransfer,
    Check,
    Other
}

public enum PaymentStatus
{
    Pending,
    Processing,
    Completed,
    Failed,
    Refunded
}
```

---

## 5. Balance Calculation Logic

### 5.1 Cari Hesap Bakiye Hesaplama

The balance is calculated from `CariHesapHareketi` entries:

```
Bakiye = Sum(Borc) - Sum(Alacak)
```

**Example Flow:**
| Step | Transaction | Borc (TL) | Alacak (TL) | Bakiye (TL) |
|------|-------------|-----------|--------------|-------------|
| 1 | Invoice #001 (300 TL) | 300 | 0 | 300 |
| 2 | Payment #001 (100 TL) | 0 | 100 | 200 |
| 3 | Payment #002 (150 TL) | 0 | 150 | 50 |
| 4 | Invoice #002 (250 TL) | 250 | 0 | 300 |

### 5.2 Service Implementation Pattern

```csharp
public class CariHesapService : ICariHesapService
{
    private readonly AccountingDbContext _db;
    
    // Create ledger entry when invoice is created
    public async Task<CariHesapHareketi> CreateFaturaHareketiAsync(
        Guid tenantId, 
        Guid invoiceId, 
        decimal tutar,
        CancellationToken ct)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == invoice.AccountId, ct);
            
        var previousBalance = await GetCurrentBalanceAsync(tenantId, account.Id, ct);
        
        var hareket = new CariHesapHareketi
        {
            TenantId = tenantId,
            AccountId = account.Id,
            InvoiceId = invoiceId,
            HareketType = CariHesapHareketType.Fatura,
            HareketTarihi = DateTimeOffset.UtcNow,
            Borc = tutar,                    // Adds to debt
            Alacak = 0,
            Bakiye = previousBalance + tutar, // Running balance
            Aciklama = $"Fatura #{invoice.InvoiceNumber}"
        };
        
        _db.CariHesapHareketleri.Add(hareket);
        
        // Update account balance
        account.Balance += tutar;
        
        await _db.SaveChangesAsync(ct);
        return hareket;
    }
    
    // Create ledger entry when payment is received
    public async Task<CariHesapHareketi> CreateOdemeHareketiAsync(
        Guid tenantId,
        Guid paymentId,
        decimal tutar,
        CancellationToken ct)
    {
        var payment = await _db.Payments
            .FirstOrDefaultAsync(x => x.Id == paymentId, ct);
            
        var account = await _db.Accounts
            .FirstOrDefaultAsync(x => x.Id == payment.AccountId, ct);
            
        var previousBalance = await GetCurrentBalanceAsync(tenantId, account.Id, ct);
        
        var hareket = new CariHesapHareketi
        {
            TenantId = tenantId,
            AccountId = account.Id,
            PaymentId = paymentId,
            HareketType = CariHesapHareketType.Odeme,
            HareketTarihi = DateTimeOffset.UtcNow,
            Borc = 0,
            Alacak = tutar,                  // Reduces debt
            Bakiye = previousBalance - tutar,
            Aciklama = $"Ödeme #{payment.PaymentNumber}"
        };
        
        _db.CariHesapHareketleri.Add(hareket);
        
        // Update account balance
        account.Balance -= tutar;
        
        await _db.SaveChangesAsync(ct);
        return hareket;
    }
    
    // Get current balance (cached from Account)
    public async Task<decimal> GetCurrentBalanceAsync(Guid tenantId, Guid accountId, CancellationToken ct)
    {
        var account = await _db.Accounts
            .Where(x => x.TenantId == tenantId && x.Id == accountId)
            .Select(x => x.Balance)
            .FirstOrDefaultAsync(ct);
        return account;
    }
    
    // Get ledger statement (hareket ekstresi)
    public async Task<IReadOnlyList<CariHesapHareketi>> GetCariHesapEkstresiAsync(
        Guid tenantId,
        Guid accountId,
        DateTimeOffset? startDate,
        DateTimeOffset? endDate,
        CancellationToken ct)
    {
        var query = _db.CariHesapHareketleri
            .Where(x => x.TenantId == tenantId && x.AccountId == accountId);
            
        if (startDate.HasValue)
            query = query.Where(x => x.HareketTarihi >= startDate.Value);
            
        if (endDate.HasValue)
            query = query.Where(x => x.HareketTarihi <= endDate.Value);
            
        return await query
            .OrderBy(x => x.HareketTarihi)
            .ToListAsync(ct);
    }
}
```

---

## 6. Service Layer Design

### 6.1 Interface Definitions

```csharp
public interface IAccountService
{
    // Existing methods
    Task<Account> CreateAsync(Guid tenantId, CreateAccountDto dto, CancellationToken ct);
    Task<Account?> GetByIdAsync(Guid tenantId, Guid accountId, CancellationToken ct);
    Task<IReadOnlyList<Account>> ListAsync(Guid tenantId, int page, int pageSize, CancellationToken ct);
    
    // New: Cari Hesap specific
    Task<Account> CreateCariHesapAsync(Guid tenantId, Guid customerId, CancellationToken ct);
    Task<Account?> GetCariHesapByCustomerAsync(Guid tenantId, Guid customerId, CancellationToken ct);
    Task<IReadOnlyList<Account>> ListCariHesaplarAsync(Guid tenantId, CancellationToken ct);
    Task UpdateBalanceAsync(Guid tenantId, Guid accountId, decimal amount, CancellationToken ct);
}

public interface ICariHesapService
{
    Task<CariHesapHareketi> CreateFaturaHareketiAsync(Guid tenantId, Guid invoiceId, decimal tutar, CancellationToken ct);
    Task<CariHesapHareketi> CreateOdemeHareketiAsync(Guid tenantId, Guid paymentId, decimal tutar, CancellationToken ct);
    Task<decimal> GetCurrentBalanceAsync(Guid tenantId, Guid accountId, CancellationToken ct);
    Task<IReadOnlyList<CariHesapHareketi>> GetCariHesapEkstresiAsync(Guid tenantId, Guid accountId, DateTimeOffset? startDate, DateTimeOffset? endDate, CancellationToken ct);
}

public interface IInvoiceService
{
    Task<Invoice> CreateAsync(Guid tenantId, CreateInvoiceDto dto, CancellationToken ct);
    Task<Invoice?> GetByIdAsync(Guid tenantId, Guid invoiceId, CancellationToken ct);
    Task<IReadOnlyList<Invoice>> ListAsync(Guid tenantId, Guid? accountId, InvoiceStatus? status, CancellationToken ct);
    Task MarkAsPaidAsync(Guid tenantId, Guid invoiceId, Guid paymentId, CancellationToken ct);
    Task SendInvoiceAsync(Guid tenantId, Guid invoiceId, CancellationToken ct);
}

public interface IPaymentService
{
    Task<Payment> CreateAsync(Guid tenantId, CreatePaymentDto dto, CancellationToken ct);
    Task<Payment?> GetByIdAsync(Guid tenantId, Guid paymentId, CancellationToken ct);
    Task<IReadOnlyList<Payment>> ListAsync(Guid tenantId, Guid? accountId, PaymentStatus? status, CancellationToken ct);
    Task ProcessPaymentAsync(Guid tenantId, Guid paymentId, CancellationToken ct);
}
```

---

## 7. Controller/Endpoint Design

### 7.1 Recommended Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| **CariHesap (Account Receivable)** ||||
| GET | /api/accounting/cari-hesaplar | List all Cari Hesap accounts | admin, accountant |
| POST | /api/accounting/cari-hesaplar | Create Cari Hesap for customer | admin |
| GET | /api/accounting/cari-hesaplar/{id} | Get Cari Hesap details | admin, accountant |
| GET | /api/accounting/cari-hesaplar/{id}/bakiye | Get current balance | admin, accountant |
| GET | /api/accounting/cari-hesaplar/{id}/ekstre | Get ledger statement | admin, accountant |
| GET | /api/accounting/cari-hesaplar/musteri/{musteriId} | Get Cari Hesap by customer | admin, accountant |
| **Account** ||||
| GET | /api/accounting/accounts | List accounts | admin, accountant |
| POST | /api/accounting/accounts | Create account | admin |
| GET | /api/accounting/accounts/{id} | Get account details | admin, accountant |
| **Invoice** ||||
| GET | /api/accounting/invoices | List invoices | admin, accountant |
| POST | /api/accounting/invoices | Create invoice | admin, accountant |
| GET | /api/accounting/invoices/{id} | Get invoice | admin, accountant |
| POST | /api/accounting/invoices/{id}/send | Send invoice | admin, accountant |
| POST | /api/accounting/invoices/{id}/cancel | Cancel invoice | admin |
| **Payment** ||||
| GET | /api/accounting/payments | List payments | admin, accountant |
| POST | /api/accounting/payments | Record payment | admin, accountant |
| POST | /api/accounting/payments/{id}/process | Process payment | admin, accountant |
| **Reports** ||||
| GET | /api/accounting/reports/aging | Aging report | admin, accountant |
| GET | /api/accounting/reports/revenue | Revenue report | admin, accountant |

### 7.2 CariHesap Controller Pattern
```csharp
[ApiController]
[Route("api/accounting/cari-hesaplar")]
[Authorize(Roles = "admin,accountant")]
public class CariHesapController : ControllerBase
{
    private readonly IAccountService _accountService;
    private readonly ICariHesapService _cariHesapService;
    
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCariHesapDto dto, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        
        var cariHesap = await _accountService.CreateCariHesapAsync(tenantId.Value, dto.CustomerId, ct);
        return CreatedAtAction(nameof(GetById), new { id = cariHesap.Id }, cariHesap);
    }
    
    [HttpGet("{id}/bakiye")]
    public async Task<IActionResult> GetBakiye(Guid id, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        
        var balance = await _cariHesapService.GetCurrentBalanceAsync(tenantId.Value, id, ct);
        return Ok(new { bakiye = balance });
    }
    
    [HttpGet("{id}/ekstre")]
    public async Task<IActionResult> GetEkstre(
        Guid id, 
        [FromQuery] DateTimeOffset? startDate,
        [FromQuery] DateTimeOffset? endDate,
        CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        
        var hareketler = await _cariHesapService.GetCariHesapEkstresiAsync(
            tenantId.Value, id, startDate, endDate, ct);
        return Ok(hareketler);
    }
    
    [HttpGet("musteri/{musteriId}")]
    public async Task<IActionResult> GetByMusteri(Guid musteriId, CancellationToken ct)
    {
        var tenantId = GetTenantIdFromClaims();
        if (tenantId is null) return Unauthorized();
        
        var cariHesap = await _accountService.GetCariHesapByCustomerAsync(tenantId.Value, musteriId, ct);
        if (cariHesap is null) return NotFound();
        return Ok(cariHesap);
    }
    
    private Guid? GetTenantIdFromClaims()
    {
        var claim = User.FindFirst("tenant_id");
        return claim != null ? Guid.Parse(claim.Value) : null;
    }
}
```

---

## 8. Updated Project Structure

```
src/Modules/Accounting/
├── Accounting.csproj
├── ModuleExtensions.cs
├── Domain/
│   └── Entities/
│       ├── Account.cs                    # Extended with CustomerId
│       ├── Invoice.cs                    # Updated with ledger relationship
│       ├── InvoiceLineItem.cs
│       ├── Payment.cs                    # Updated with ledger relationship
│       └── CariHesapHareketi.cs          # NEW: Ledger entry entity
├── Data/
│   ├── AccountingDbContext.cs            # Updated with new entity
│   └── Migrations/
├── Services/
│   ├── IAccountService.cs                # Extended with Cari methods
│   ├── AccountService.cs
│   ├── ICariHesapService.cs              # NEW: Ledger service interface
│   ├── CariHesapService.cs               # NEW: Ledger service implementation
│   ├── IInvoiceService.cs
│   ├── InvoiceService.cs
│   ├── IPaymentService.cs
│   └── PaymentService.cs
├── Api/
│   └── Controllers/
│       ├── AccountsController.cs
│       ├── CariHesapController.cs        # NEW
│       ├── InvoicesController.cs
│       └── PaymentsController.cs
└── DTO/
    └── Dtos.cs                           # Extended with Cari DTOs
```

---

## 9. Multi-Tenant Considerations

### 9.1 Data Isolation
- **AccountNumber** must be unique per tenant: Add composite index `(TenantId, AccountNumber)`
- **InvoiceNumber** must be unique per tenant: Add composite index `(TenantId, InvoiceNumber)`
- **PaymentNumber** must be unique per tenant: Add composite index `(TenantId, PaymentNumber)`
- **CustomerId** per tenant: Add composite index `(TenantId, CustomerId)` for CariHesap lookups

### 9.2 Financial Implications
- **Never delete** financial records (invoices, payments, CariHesapHareketi) - use status flags for void/cancel
- Implement **audit trail** - consider adding CreatedBy, UpdatedBy to all financial entities
- Use **decimal** type for all money fields (NOT float/double)
- Consider **fiscal periods** for reporting (not in v1, but plan for it)

### 9.3 Integration Points
- Link invoices to Operations (work orders) for automatic billing
- Link to Stock for material costs
- Consider integration with external payment gateways (future)
- **Customer module**: CariHesap.CustomerId links to Customer

---

## 10. Implementation Phases

### Phase 1: Core Accounting + Cari Hesap Foundation
- [x] Create Accounting project and solution entry
- [x] Implement Account entity and service
- [x] Implement Invoice entity and service
- [x] Implement basic CRUD controllers
- [ ] Add migration and database setup
- [ ] **Add CustomerId to Account entity**
- [ ] **Create CariHesapHareketi entity**
- [ ] **Update DbContext with new relationships**
- [ ] **Implement ICariHesapService**
- [ ] **Implement balance calculation logic**

### Phase 2: Payments + Ledger
- [ ] Implement Payment entity
- [ ] Payment recording and processing
- [ ] Link payments to invoices
- [ ] **Auto-create ledger entries on invoice/payment**
- [ ] **Implement CariHesapEkstresi (ledger statement) endpoint**

### Phase 3: Integration
- [ ] Link invoices to operations
- [ ] Integrate with Stock for materials
- [ ] Basic reporting (aging, revenue)

### Phase 4: Advanced Features
- [ ] Invoice sending (email/PDF)
- [ ] Payment gateway integration
- [ ] Advanced reporting
- [ ] Tax calculation

---

## 11. Risks and Considerations

| Risk | Mitigation |
|------|------------|
| Data isolation breach | Always filter by TenantId; add database-level RLS in future |
| Financial data loss | Never allow hard deletes; implement soft delete |
| Calculation errors | Use decimal for all financial calculations; unit test edge cases |
| Schema changes | Version migrations carefully; maintain backward compatibility |
| Performance at scale | Add proper indexes; consider pagination for all list endpoints |
| Balance inconsistency | Use database transactions; recalculate balance on demand |
| Missing customer link | Validate CustomerId exists before creating CariHesap |

---

## 12. Business Flow Examples

### Example 1: Creating Invoice and Payment Flow

```csharp
// 1. Create Invoice for customer service (300 TL)
var invoice = await _invoiceService.CreateAsync(tenantId, new CreateInvoiceDto
{
    AccountId = cariHesapId,
    OperationId = workOrderId,
    LineItems = new[] { new LineItemDto { Description = "Service", UnitPrice = 300 } }
});

// 2. System automatically creates ledger entry
// Borc: 300, Alacak: 0, Bakiye: 300

// 3. Customer pays 100 TL
var payment = await _paymentService.CreateAsync(tenantId, new CreatePaymentDto
{
    AccountId = cariHesapId,
    InvoiceId = invoice.Id,
    Amount = 100,
    Method = PaymentMethod.BankTransfer
});

// 4. System automatically creates ledger entry  
// Borc: 0, Alacak: 100, Bakiye: 200

// Result: Customer has 200 TL remaining debt in Cari Hesap
```

### Example 2: Cari Hesap Ekstresi Output

```json
{
  "cariHesapId": "abc-123",
  "musteri": "Acme Inc.",
  "bakiye": 200.00,
  "hareketler": [
    {
      "tarih": "2024-01-15",
      "tip": "Fatura",
      "referans": "INV-001",
      "borc": 300.00,
      "alacak": 0.00,
      "bakiye": 300.00,
      "aciklama": "Service - Work Order #WO-123"
    },
    {
      "tarih": "2024-01-20",
      "tip": "Odeme",
      "referans": "PAY-001",
      "borc": 0.00,
      "alacak": 100.00,
      "bakiye": 200.00,
      "aciklama": "Bank Transfer"
    }
  ]
}
```
