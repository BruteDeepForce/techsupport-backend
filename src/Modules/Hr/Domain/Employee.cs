using Modules.HR.Domain.Bordro;
using TechSupport.Hr.Domain;

namespace Modules.HR.Domain;

public enum EmployeeStatus
{
    Active = 1,
    Passive = 2,
    OnLeave = 3,
    Terminated = 4
}

public class Employee
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid BranchId { get; set; }
    public Guid? UserId { get; set; } //! appuserid mi olacak karar verilmedi
    public Guid? PositionId { get; set; }
    public Position? Position { get; set; }
    public Guid? DepartmentId { get; set; }
    public Department? Department { get; set; }
    public string EmployeeNo { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? ProfileImageUrl { get; set; }
    public EmployeeStatus Status { get; set; } = EmployeeStatus.Active;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
    public DateTime? JobsStartDateUtc { get; set; }
    public DateTime? JobsEndDateUtc { get; set; }
    public DateTime? DeletedAtUtc { get; set; }
    public ICollection<Leave> EmployeeLeaves { get; set; } = new List<Leave>();
    public ICollection<Advance> EmployeeAdvances { get; set; } = new List<Advance>();
    public ICollection<BordroEmployee> BordroEmployees { get; set; } = new List<BordroEmployee>();
    public ICollection<EmployeeSalary> EmployeeSalaries { get; set; } = new List<EmployeeSalary>();
    public ICollection<DisciplineEmployeeRecord> DisciplineEmployeeRecords { get; set; } = new List<DisciplineEmployeeRecord>();
    public ICollection<RewardEmployeeRecord> RewardEmployeeRecords { get; set; } = new List<RewardEmployeeRecord>();
    public ICollection<EmployeePerformanceReport> EmployeePerformanceReports { get; set; } = new List<EmployeePerformanceReport>();
}
