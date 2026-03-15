using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Domain.Entities;

namespace TechSupport.Reports.Data;

public class ReportDbContext : DbContext
{
    public ReportDbContext(DbContextOptions<ReportDbContext> options) : base(options)
    {
    }

    public DbSet<TenantReportSummary> TenantReportSummaries => Set<TenantReportSummary>();
    public DbSet<BranchReportSummary> BranchReportSummaries => Set<BranchReportSummary>();
    public DbSet<ReportMetric> ReportMetrics => Set<ReportMetric>();
    public DbSet<GeneratedReport> GeneratedReports => Set<GeneratedReport>();
    public DbSet<ProcessedReportEvent> ProcessedReportEvents => Set<ProcessedReportEvent>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("reports");

        modelBuilder.Entity<TenantReportSummary>(b =>
        {
            b.ToTable("tenant_report_summaries");
            b.HasKey(x => x.Id);
            b.HasIndex(x => x.TenantId).IsUnique();
        });

        modelBuilder.Entity<BranchReportSummary>(b =>
        {
            b.ToTable("branch_report_summaries");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.BranchId }).IsUnique();
        });

        modelBuilder.Entity<ReportMetric>(b =>
        {
            b.ToTable("report_metrics");
            b.HasKey(x => x.Id);
            b.HasIndex(x => new { x.TenantId, x.BranchId, x.MetricType, x.PeriodType, x.PeriodDate }).IsUnique();
        });

        modelBuilder.Entity<GeneratedReport>(b =>
        {
            b.ToTable("generated_reports");
            b.HasKey(x => x.Id);
            b.Property(x => x.Name).HasMaxLength(256).IsRequired();
            b.Property(x => x.Description).HasMaxLength(4000);
            b.HasIndex(x => new { x.TenantId, x.PeriodType, x.PeriodDate, x.GeneratedAtUtc });
        });

        modelBuilder.Entity<ProcessedReportEvent>(b =>
        {
            b.ToTable("processed_report_events");
            b.HasKey(x => x.Id);
            b.Property(x => x.EventName).HasMaxLength(256).IsRequired();
            b.HasIndex(x => new { x.EventName, x.MessageId }).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}