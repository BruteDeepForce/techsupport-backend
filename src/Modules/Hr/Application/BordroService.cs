using System.Security.Cryptography.Xml;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using Modules.HR.Domain;
using Modules.HR.Domain.Bordro;
using Modules.HR.DTO;
using Modules.HR.Infrastructure;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Modules.HR.Application;

public interface IBordroService
{
    Task<HRServiceResult<BordroDonemResponse>> CreateDonemAsync(Guid tenantId, CreateBordroDonemRequest request, CancellationToken ct);
    Task<HRServiceResult<BordroDonemResponse>> GetDonemByIdAsync(Guid tenantId, Guid id, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<BordroDonemResponse>>> ListDonemAsync(Guid tenantId, Guid branchId, bool includeClosed, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>> CalculateDonemAsync(Guid tenantId, Guid bordroDonemId, CancellationToken ct);
    Task<HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>> ListDonemEmployeesAsync(Guid tenantId, Guid bordroDonemId, CancellationToken ct);
    Task<HRServiceResult<BordroEmployeeDetailResponse>> GetBordroEmployeeDetailAsync(Guid tenantId, Guid bordroEmployeeId, CancellationToken ct);
    Task<HRServiceResult<byte[]>> GenerateBordroEmployeePdfAsync(Guid tenantId, Guid bordroEmployeeId, CancellationToken ct);
    Task<HRServiceResult<BordroKalemResponse>> AddKalemAsync(Guid tenantId, CreateBordroKalemRequest request, CancellationToken ct);
    Task<HRServiceResult<BordroDonemResponse>> UpdateDonemStatusAsync(Guid tenantId, Guid bordroDonemId, UpdateBordroDonemStatusRequest request, CancellationToken ct);
}

public sealed class BordroService : IBordroService
{
    private readonly HRDbContext _db;
    private const string AccentBlue = "#1339A5";
    private const string AccentPurple = "#5B21B6";
    private const string TextDark = "#0F172A";

    public BordroService(HRDbContext db)
    {
        _db = db;
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public async Task<HRServiceResult<BordroDonemResponse>> CreateDonemAsync(Guid tenantId, CreateBordroDonemRequest request, CancellationToken ct)
    {
        if (tenantId == Guid.Empty)
        {
            return HRServiceResult<BordroDonemResponse>.Fail("TenantId is required.");
        }

        if (request.Year < 2000 || request.Month is < 1 or > 12)
        {
            return HRServiceResult<BordroDonemResponse>.Fail("Year/Month is invalid.");
        }

        var baslangic = request.BaslangicTarihi.Date;
        var bitis = request.BitisTarihi.Date;
        if (baslangic > bitis)
        {
            return HRServiceResult<BordroDonemResponse>.Fail("BaslangicTarihi must be earlier than or equal to BitisTarihi.");
        }

        var branchId = request.BranchId;

        var exists = await _db.BordroDonems
            .AnyAsync(x => x.TenantId == tenantId && x.BranchId == branchId && x.Year == request.Year && x.Month == request.Month, ct);

        if (exists)
        {
            return HRServiceResult<BordroDonemResponse>.Conflict("Bordro dönemi already exists for this branch/month.");
        }

        var donem = new BordroDonem
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Year = request.Year,
            Month = request.Month,
            BaslangicTarihi = baslangic,
            BitisTarihi = bitis,
            Status = BordroPeriod.Open,
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.BordroDonems.Add(donem);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<BordroDonemResponse>.Ok(ToResponse(donem));
    }

    public async Task<HRServiceResult<BordroDonemResponse>> GetDonemByIdAsync(Guid tenantId, Guid id, CancellationToken ct)
    {
        var donem = await _db.BordroDonems
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && x.TenantId == tenantId, ct);

        return donem is null
            ? HRServiceResult<BordroDonemResponse>.NotFound("Bordro dönemi not found.")
            : HRServiceResult<BordroDonemResponse>.Ok(ToResponse(donem));
    }

    public async Task<HRServiceResult<IReadOnlyCollection<BordroDonemResponse>>> ListDonemAsync(Guid tenantId, Guid branchId, bool includeClosed, CancellationToken ct)
    {
        var query = _db.BordroDonems
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId);

        if (branchId != Guid.Empty)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        if (!includeClosed)
        {
            query = query.Where(x => x.Status == BordroPeriod.Open);
        }

        var items = await query
            .OrderByDescending(x => x.Year)
            .ThenByDescending(x => x.Month)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<BordroDonemResponse>>.Ok(items.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>> CalculateDonemAsync(Guid tenantId, Guid bordroDonemId, CancellationToken ct)
    {
        var donem = await _db.BordroDonems
           .FirstOrDefaultAsync(x => x.Id == bordroDonemId && x.TenantId == tenantId, ct);

        if (donem is null)
        {
            return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.NotFound("Bordro dönemi not found.");
        }

        if (donem.Status == BordroPeriod.Closed)
        {
            return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.Conflict("Closed bordro dönemi cannot be recalculated.");
        }

        var employees = await _db.Employees
            .AsNoTracking()
            .Where(x =>
                x.TenantId == tenantId &&
                (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
                x.DeletedAtUtc == null &&
                x.Status == EmployeeStatus.Active)
            .ToListAsync(ct);

        if (employees.Count == 0)
        {
            return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.Ok([]);
        }

        var employeeIds = employees.Select(x => x.Id).ToArray();

        var AdvancesByEmployee = await _db.Advances
            .AsNoTracking()
            .Where(x =>
                x.TenantId == tenantId &&
                (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
                x.Status == AdvanceStatus.Approved &&
                employeeIds.Contains(x.EmployeeId) &&
                x.CreatedAtUtc.Date >= donem.BaslangicTarihi.Date &&
                x.CreatedAtUtc.Date <= donem.BitisTarihi.Date)
            .GroupBy(x => x.EmployeeId)
            .Select(g => new
            {
                EmployeeId = g.Key,
                Total = g.Sum(x => x.Amount)
            })
            .ToListAsync(ct);

        var advanceComponent = await EnsureAdvanceDeductionComponentAsync(tenantId, donem.BranchId, ct);

        var SalariesEmployee = await _db.EmployeeSalaries
        .AsNoTracking()
        .Where(x => x.TenantId == tenantId &&
        (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
        employeeIds.Contains(x.EmployeeId) &&
        x.EffectiveFrom.Date <= donem.BitisTarihi.Date &&
        (x.EffectiveTo == null || x.EffectiveTo.Value.Date >= donem.BitisTarihi.Date))
        .GroupBy(x => x.EmployeeId)
        .Select(g => new
        {
            EmployeeId = g.Key,
            NetSalary = g.OrderByDescending(x => x.EffectiveFrom).FirstOrDefault()!.NetSalary
        })
        .ToListAsync(ct);

        var salaryComponent = await EnsureSalaryEarningComponentAsync(tenantId, donem.BranchId, ct);

        var DisciplineEmployee = await _db.DisciplineEmployeeRecords
        .Include(x => x.Discipline)
        .AsNoTracking()
        .Where(x => x.TenantId == tenantId &&
        (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
        employeeIds.Contains(x.EmployeeId) &&
        x.CreatedAtUtc.Date >= donem.BaslangicTarihi.Date &&
        x.CreatedAtUtc.Date <= donem.BitisTarihi.Date)
        .GroupBy(x => x.EmployeeId)
        .Select(g => new
        {
            EmployeeId = g.Key,
            TotalPenalty = g.Sum(x => x.Discipline.PenaltyAmount)
        })
        .ToListAsync(ct);

        var disciplineCOmponent = await EnsureDisciplineDeductionComponentAsync(tenantId, donem.BranchId, ct);

        var rewardEmployee = await _db.RewardEmployeeRecords
        .Include(x => x.Reward)
        .AsNoTracking()
        .Where(x => x.TenantId == tenantId &&
        (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
        employeeIds.Contains(x.EmployeeId) &&
        x.CreatedAtUtc.Date >= donem.BaslangicTarihi.Date &&
        x.CreatedAtUtc.Date <= donem.BitisTarihi.Date)
        .GroupBy(x => x.EmployeeId)
        .Select(g => new
        {
            EmployeeId = g.Key,
            TotalReward = g.Sum(x => x.Reward.RewardAmount)
        })
        .ToListAsync(ct);

        var rewardComponent = await EnsureRewardEarningComponentAsync(tenantId, donem.BranchId, ct);

        var leaveEmployee = await _db.Leaves.Include(x=> x.LeaveDeduction)
        .AsNoTracking()
        .Where(x => x.TenantId == tenantId &&
        (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId) &&
        x.Status == LeaveStatus.Approved &&
        employeeIds.Contains(x.EmployeeId) &&
        x.CreatedAtUtc.Date >= donem.BaslangicTarihi.Date &&
        x.CreatedAtUtc.Date <= donem.BitisTarihi.Date)
        .GroupBy(x=> x.EmployeeId)
        .Select(g => new
        {
            EmployeeId = g.Key,
            TotalDeduction = g.Sum(x=> x.LeaveDeduction != null ? x.LeaveDeduction.DeductionAmount : 0)
        })
        .ToListAsync(ct);

        var leaveComponent = await EnsureLeaveDeductionComponentAsync(tenantId, donem.BranchId, ct);

        var existingBordros = await _db.BordroEmployees
        .Include(i => i.BordroKalems)
        .Where(x => x.TenantId == tenantId
        && x.BordroDonemId == bordroDonemId
        && (donem.BranchId == Guid.Empty || x.BranchId == donem.BranchId))
        .ToListAsync(ct);

        if (existingBordros.Count > 0)
        {
            _db.BordroEmployees.RemoveRange(existingBordros);
        }

        foreach (var employe in employees)
        {
            var kalemler = new List<BordroKalem>();
            var BordroEmployeeID = Guid.NewGuid();
            if (advanceComponent != null)
            {
                var advance = AdvancesByEmployee.FirstOrDefault(x => x.EmployeeId == employe.Id);
                if (advance != null)
                {
                    var kalem = new BordroKalem
                    {
                        Id = Guid.NewGuid(),
                        TenantId = tenantId,
                        BranchId = donem.BranchId,
                        BordroEmployeeId = BordroEmployeeID,
                        BordroComponentId = advanceComponent.Id,
                        Type = BordroKalemType.Deductions,
                        Description = "Onaylanan Avans Kesintisi",
                        Amount = advance.Total,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    kalemler.Add(kalem);
                }
            }
            if (salaryComponent != null)
            {
                var salary = SalariesEmployee.FirstOrDefault(x => x.EmployeeId == employe.Id);
                if (salary != null)
                {
                    var kalem = new BordroKalem
                    {
                        Id = Guid.NewGuid(),
                        TenantId = tenantId,
                        BranchId = donem.BranchId,
                        BordroEmployeeId = BordroEmployeeID,
                        BordroComponentId = salaryComponent.Id,
                        Type = BordroKalemType.Earnings,
                        Description = "Maaş Kazancı",
                        Amount = salary.NetSalary,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    kalemler.Add(kalem);
                }
            }
            if (disciplineCOmponent != null)
            {
                var discipline = DisciplineEmployee.FirstOrDefault(x => x.EmployeeId == employe.Id);
                if (discipline != null)
                {
                    var kalem = new BordroKalem
                    {
                        Id = Guid.NewGuid(),
                        TenantId = tenantId,
                        BranchId = donem.BranchId,
                        BordroEmployeeId = BordroEmployeeID,
                        BordroComponentId = disciplineCOmponent.Id,
                        Type = BordroKalemType.Deductions,
                        Description = "Disiplin Cezası",
                        Amount = discipline.TotalPenalty,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    kalemler.Add(kalem);
                }
            }
            if (rewardComponent != null)
            {
                var reward = rewardEmployee.FirstOrDefault(x => x.EmployeeId == employe.Id);
                if (reward != null)
                {
                    var kalem = new BordroKalem
                    {
                        Id = Guid.NewGuid(),
                        TenantId = tenantId,
                        BranchId = donem.BranchId,
                        BordroEmployeeId = BordroEmployeeID,
                        BordroComponentId = rewardComponent.Id,
                        Type = BordroKalemType.Earnings,
                        Description = "Ödül Kazancı",
                        Amount = reward.TotalReward,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    kalemler.Add(kalem);
                }
            }
            if (leaveComponent != null)
            {
                var leave = leaveEmployee.FirstOrDefault(x => x.EmployeeId == employe.Id);
                if (leave != null)
                {
                    var kalem = new BordroKalem
                    {
                        Id = Guid.NewGuid(),
                        TenantId = tenantId,
                        BranchId = donem.BranchId,
                        BordroEmployeeId = BordroEmployeeID,
                        BordroComponentId = leaveComponent.Id,
                        Type = BordroKalemType.Deductions,
                        Description = "İzin Kesintisi",
                        Amount = leave.TotalDeduction,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    kalemler.Add(kalem);
                }
            }

            var totalEarnings = kalemler.Where(x=> x.Type == BordroKalemType.Earnings).Sum(x => x.Amount);
            var totalDeductions = kalemler.Where(x => x.Type == BordroKalemType.Deductions).Sum(x => x.Amount);
            var netPay = totalEarnings - totalDeductions;

            var bordroEmployee = new BordroEmployee
            {
                Id = BordroEmployeeID,
                TenantId = tenantId,
                BranchId = donem.BranchId,
                DepartmentId = employe.DepartmentId,
                BordroDonemId = donem.Id,
                EmployeeId = employe.Id,
                EmployeeName = employe.FullName,
                TotalEarnings = totalEarnings,
                TotalDeductions = totalDeductions,
                NetPay = netPay,
                CreatedAtUtc = DateTime.UtcNow,
                BordroKalems = kalemler
            };

            _db.BordroEmployees.Add(bordroEmployee);
        }
        await _db.SaveChangesAsync(ct);

        var response = await _db.BordroEmployees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BordroDonemId == donem.Id)
            .OrderBy(x => x.EmployeeName)
            .ToListAsync(ct);
        
        return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.Ok(response.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>> ListDonemEmployeesAsync(Guid tenantId, Guid bordroDonemId, CancellationToken ct)
    {
        var exists = await _db.BordroDonems
            .AsNoTracking()
            .AnyAsync(x => x.Id == bordroDonemId && x.TenantId == tenantId, ct);

        if (!exists)
        {
            return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.NotFound("Bordro dönemi not found.");
        }

        var employees = await _db.BordroEmployees
            .AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.BordroDonemId == bordroDonemId)
            .OrderBy(x => x.EmployeeName)
            .ToListAsync(ct);

        return HRServiceResult<IReadOnlyCollection<BordroEmployeeResponse>>.Ok(employees.Select(ToResponse).ToList());
    }

    public async Task<HRServiceResult<BordroEmployeeDetailResponse>> GetBordroEmployeeDetailAsync(Guid tenantId, Guid bordroEmployeeId, CancellationToken ct)
    {
        var bordroEmployee = await _db.BordroEmployees
            .AsNoTracking()
            .Include(x => x.BordroKalems)
            .FirstOrDefaultAsync(x => x.Id == bordroEmployeeId && x.TenantId == tenantId, ct);

        if (bordroEmployee is null)
        {
            return HRServiceResult<BordroEmployeeDetailResponse>.NotFound("Bordro employee not found.");
        }

        var detail = new BordroEmployeeDetailResponse(
            Employee: ToResponse(bordroEmployee),
            Kalemler: bordroEmployee.BordroKalems
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(ToResponse)
                .ToList());

        return HRServiceResult<BordroEmployeeDetailResponse>.Ok(detail);
    }

    public async Task<HRServiceResult<byte[]>> GenerateBordroEmployeePdfAsync(Guid tenantId, Guid bordroEmployeeId, CancellationToken ct)
    {
        var bordroEmployee = await _db.BordroEmployees
            .AsNoTracking()
            .Include(x => x.BordroDonem)
            .Include(x=> x.Employee)
                .ThenInclude(x=> x.Position)
            .Include(x => x.Department)
            .Include(x => x.BordroKalems)
                .ThenInclude(x => x.BordroComponent)
            .FirstOrDefaultAsync(x => x.Id == bordroEmployeeId && x.TenantId == tenantId, ct);

        if (bordroEmployee is null)
        {
            return HRServiceResult<byte[]>.NotFound("Bordro employee not found.");
        }

        var pdfBytes = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(28);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(TextDark));

                page.Header().Column(header =>
                {
                    header.Item().Row(row =>
                    {
                        row.RelativeItem().Column(left =>
                        {
                            left.Item().Text("BORDRO / HAKEDİŞ")
                                .FontSize(24)
                                .SemiBold()
                                .FontColor(AccentBlue);
                            left.Item().PaddingTop(4).Text(
                                $"{bordroEmployee.BordroDonem.Month:00}/{bordroEmployee.BordroDonem.Year} Dönemi");
                        });

                        row.ConstantItem(180).AlignRight().Column(right =>
                        {
                            right.Item().AlignRight().Text($"No: {bordroEmployee.Id.ToString()[..8].ToUpperInvariant()}");
                            right.Item().AlignRight().Text($"Oluşturulma Tarihi: {bordroEmployee.CreatedAtUtc:dd.MM.yyyy}");
                            right.Item().AlignRight().Text($"Durum: {bordroEmployee.BordroDonem.Status}");
                        });
                    });
                });

                page.Content().PaddingTop(18).Column(content =>
                {
                    content.Spacing(14);

                    content.Item().Container()
                        .Border(1)
                        .BorderColor(Colors.Grey.Lighten2)
                        .Padding(14)
                        .Column(col =>
                        {
                            col.Spacing(6);
                            col.Item().Text($"Personel: {bordroEmployee.EmployeeName}").SemiBold();
                            col.Item().Text($"Mesleki Rol: {bordroEmployee.Employee.Position?.Name ?? "Belirtilmemiş"}"); // Şube adı eklenebilir
                            col.Item().Text($"Departman: {bordroEmployee.Department?.Name ?? "Merkez Departman"}");
                            col.Item().Text(
                                $"Dönem Aralığı: {bordroEmployee.BordroDonem.BaslangicTarihi:dd.MM.yyyy} - {bordroEmployee.BordroDonem.BitisTarihi:dd.MM.yyyy}");
                        });

                    content.Item().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn(2);
                        });

                        table.Header(header =>
                        {
                            header.Cell().Element(PdfHeaderCell).Text("Kalem");
                            header.Cell().Element(PdfHeaderCell).AlignCenter().Text("Tip");
                            header.Cell().Element(PdfHeaderCell).AlignRight().Text("Tutar");
                        });

                        foreach (var kalem in bordroEmployee.BordroKalems.OrderBy(x => x.Type).ThenBy(x => x.Description))
                        {
                            table.Cell().Element(PdfBodyCell).Text(kalem.Description);
                            table.Cell().Element(PdfBodyCell).AlignCenter().Text(KalemTypeLabel(kalem.Type));
                            table.Cell().Element(PdfBodyCell).AlignRight().Text($"{kalem.Amount:N2} ₺");
                        }
                    });

                    content.Item().AlignRight().Width(260).Container()
                        .Border(1)
                        .BorderColor(Colors.Grey.Lighten2)
                        .Padding(14)
                        .Column(summary =>
                        {
                            summary.Spacing(8);
                            summary.Item().Row(r =>
                            {
                                r.RelativeItem().Text("Toplam Kazanç").SemiBold();
                                r.ConstantItem(90).AlignRight().Text($"{bordroEmployee.TotalEarnings:N2} ₺").SemiBold();
                            });
                            summary.Item().Row(r =>
                            {
                                r.RelativeItem().Text("Toplam Kesinti").SemiBold();
                                r.ConstantItem(90).AlignRight().Text($"{bordroEmployee.TotalDeductions:N2} ₺").SemiBold();
                            });
                            summary.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                            summary.Item().Row(r =>
                            {
                                r.RelativeItem().Text("Net Ele Geçen")
                                    .FontColor(AccentPurple)
                                    .FontSize(12)
                                    .SemiBold();
                                r.ConstantItem(90).AlignRight().Text($"{bordroEmployee.NetPay:N2} ₺")
                                    .FontColor(AccentPurple)
                                    .FontSize(12)
                                    .SemiBold();
                            });
                        });
                });

                page.Footer().AlignRight().Text(
                    $"Lineer Destek Bordro Yönetim Sistemi| {DateTimeOffset.UtcNow:dd.MM.yyyy HH:mm}",
                    TextStyle.Default.FontSize(8).FontColor(Colors.Grey.Darken1));
            });
        }).GeneratePdf();

        return HRServiceResult<byte[]>.Ok(pdfBytes);
    }

    public async Task<HRServiceResult<BordroKalemResponse>> AddKalemAsync(Guid tenantId, CreateBordroKalemRequest request, CancellationToken ct)
    {
        if (request.BordroEmployeeId == Guid.Empty || request.BordroComponentId == Guid.Empty)
        {
            return HRServiceResult<BordroKalemResponse>.Fail("BordroEmployeeId and BordroComponentId are required.");
        }

        if (request.Amount <= 0)
        {
            return HRServiceResult<BordroKalemResponse>.Fail("Amount must be greater than zero.");
        }

        var bordroEmployee = await _db.BordroEmployees
            .Include(x => x.BordroDonem)
            .Include(x => x.BordroKalems)
            .FirstOrDefaultAsync(x => x.Id == request.BordroEmployeeId && x.TenantId == tenantId, ct);

        if (bordroEmployee is null)
        {
            return HRServiceResult<BordroKalemResponse>.NotFound("Bordro employee not found.");
        }

        if (bordroEmployee.BordroDonem.Status == BordroPeriod.Closed)
        {
            return HRServiceResult<BordroKalemResponse>.Conflict("Cannot add kalem to a closed bordro dönemi.");
        }

        var component = await _db.BordroComponents
            .AsNoTracking()
            .FirstOrDefaultAsync(x =>
                x.Id == request.BordroComponentId &&
                x.TenantId == tenantId &&
                x.BranchId == bordroEmployee.BranchId,
                ct);

        if (component is null)
        {
            return HRServiceResult<BordroKalemResponse>.NotFound("Bordro component not found.");
        }

        var kalem = new BordroKalem
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = bordroEmployee.BranchId,
            BordroEmployeeId = bordroEmployee.Id,
            BordroComponentId = component.Id,
            Type = request.Type ?? component.Type,
            Description = string.IsNullOrWhiteSpace(request.Description) ? component.Name : request.Description.Trim(),
            Amount = decimal.Round(request.Amount, 2),
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.BordroKalems.Add(kalem);
        bordroEmployee.BordroKalems.Add(kalem);

        RecalculateTotals(bordroEmployee);
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<BordroKalemResponse>.Ok(ToResponse(kalem));
    }

    public async Task<HRServiceResult<BordroDonemResponse>> UpdateDonemStatusAsync(Guid tenantId, Guid bordroDonemId, UpdateBordroDonemStatusRequest request, CancellationToken ct)
    {
        var donem = await _db.BordroDonems
            .FirstOrDefaultAsync(x => x.Id == bordroDonemId && x.TenantId == tenantId, ct);

        if (donem is null)
        {
            return HRServiceResult<BordroDonemResponse>.NotFound("Bordro dönemi not found.");
        }

        donem.Status = request.Status;
        await _db.SaveChangesAsync(ct);

        return HRServiceResult<BordroDonemResponse>.Ok(ToResponse(donem));
    }

    private async Task<BordroComponent> EnsureAdvanceDeductionComponentAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        var component = await _db.BordroComponents
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.Code == "ADVANCE_DEDUCTION",
                ct);

        if (component is not null)
        {
            return component;
        }

        component = new BordroComponent
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Code = "ADVANCE_DEDUCTION",
            Name = "Advance deduction",
            Type = BordroKalemType.Deductions
        };

        _db.BordroComponents.Add(component);
        await _db.SaveChangesAsync(ct);

        return component;
    }

    private async Task<BordroComponent> EnsureSalaryEarningComponentAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        var component = await _db.BordroComponents
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.Code == "SALARY_EARNING",
                ct);

        if (component is not null)
        {
            return component;
        }

        component = new BordroComponent
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Code = "SALARY_EARNING",
            Name = "Salary earning",
            Type = BordroKalemType.Earnings
        };

        _db.BordroComponents.Add(component);
        await _db.SaveChangesAsync(ct);

        return component;
    }
    private async Task<BordroComponent> EnsureDisciplineDeductionComponentAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        var component = await _db.BordroComponents
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.Code == "DISCIPLINE_DEDUCTION",
                ct);

        if (component is not null)
        {
            return component;
        }

        component = new BordroComponent
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Code = "DISCIPLINE_DEDUCTION",
            Name = "Discipline deduction",
            Type = BordroKalemType.Deductions
        };

        _db.BordroComponents.Add(component);
        await _db.SaveChangesAsync(ct);

        return component;
    }

    private async Task<BordroComponent> EnsureRewardEarningComponentAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        var component = await _db.BordroComponents
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.Code == "REWARD_EARNING",
                ct);

        if (component is not null)
        {
            return component;
        }

        component = new BordroComponent
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Code = "REWARD_EARNING",
            Name = "Reward earning",
            Type = BordroKalemType.Earnings
        };

        _db.BordroComponents.Add(component);
        await _db.SaveChangesAsync(ct);

        return component;
    }

    private async Task<BordroComponent> EnsureLeaveDeductionComponentAsync(Guid tenantId, Guid branchId, CancellationToken ct)
    {
        var component = await _db.BordroComponents
            .FirstOrDefaultAsync(x =>
                x.TenantId == tenantId &&
                x.BranchId == branchId &&
                x.Code == "LEAVE_DEDUCTION",
                ct);

        if (component is not null)
        {
            return component;
        }

        component = new BordroComponent
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            BranchId = branchId,
            Code = "LEAVE_DEDUCTION",
            Name = "Leave deduction",
            Type = BordroKalemType.Deductions
        };

        _db.BordroComponents.Add(component);
        await _db.SaveChangesAsync(ct);

        return component;
    }

    private static void RecalculateTotals(BordroEmployee bordroEmployee)
    {
        bordroEmployee.TotalEarnings = bordroEmployee.BordroKalems
            .Where(x => x.Type == BordroKalemType.Earnings)
            .Sum(x => x.Amount);

        bordroEmployee.TotalDeductions = bordroEmployee.BordroKalems
            .Where(x => x.Type == BordroKalemType.Deductions)
            .Sum(x => x.Amount);

        bordroEmployee.NetPay = bordroEmployee.TotalEarnings - bordroEmployee.TotalDeductions;
    }

    private static BordroDonemResponse ToResponse(BordroDonem donem)
        => new(
            donem.Id,
            donem.TenantId,
            donem.BranchId,
            donem.Year,
            donem.Month,
            donem.BaslangicTarihi,
            donem.BitisTarihi,
            donem.Status,
            donem.CreatedAtUtc);

    private static BordroEmployeeResponse ToResponse(BordroEmployee bordroEmployee)
        => new(
            bordroEmployee.Id,
            bordroEmployee.TenantId,
            bordroEmployee.BranchId,
            bordroEmployee.DepartmentId,
            bordroEmployee.BordroDonemId,
            bordroEmployee.EmployeeId,
            bordroEmployee.EmployeeName,
            bordroEmployee.TotalEarnings,
            bordroEmployee.TotalDeductions,
            bordroEmployee.NetPay,
            bordroEmployee.CreatedAtUtc);

    private static BordroKalemResponse ToResponse(BordroKalem kalem)
        => new(
            kalem.Id,
            kalem.TenantId,
            kalem.BranchId,
            kalem.BordroEmployeeId,
            kalem.BordroComponentId,
            kalem.Type,
            kalem.Description,
            kalem.Amount,
            kalem.CreatedAtUtc);

    private static string KalemTypeLabel(BordroKalemType type)
        => type switch
        {
            BordroKalemType.Earnings => "Kazanç",
            BordroKalemType.Deductions => "Kesinti",
            _ => "Diğer"
        };

    private static IContainer PdfHeaderCell(IContainer container)
        => container
            .Background(AccentBlue)
            .PaddingVertical(8)
            .PaddingHorizontal(8)
            .DefaultTextStyle(x => x.FontColor(Colors.White).FontSize(10).SemiBold());

    private static IContainer PdfBodyCell(IContainer container)
        => container
            .BorderBottom(1)
            .BorderColor(Colors.Grey.Lighten2)
            .PaddingVertical(8)
            .PaddingHorizontal(8);
}
