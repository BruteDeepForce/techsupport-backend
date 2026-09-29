using Microsoft.EntityFrameworkCore;
using TechSupport.Reports.Domain.Entities;
using TechSupport.Reports.Contracts;

namespace TechSupport.Reports.Data;

public class ReportDbContext : DbContext
{
    public ReportDbContext(DbContextOptions<ReportDbContext> options) : base(options)
    {
    }

    public DbSet<TenantReportSummary> TenantReportSummaries => Set<TenantReportSummary>();
    public DbSet<TenantReportMetric> TenantReportMetrics => Set<TenantReportMetric>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("reports");

        modelBuilder.Entity<TenantReportSummary>(b =>
        {
            b.ToTable("tenant_report_summaries");
            b.HasKey(x => x.Id);
            b.HasIndex(x => x.TenantId).IsUnique();
            b.Property(x => x.TenantName).HasMaxLength(200).IsRequired();
        });

        modelBuilder.Entity<TenantReportMetric>(b =>
        {
            b.ToTable("tenant_report_metrics");
            b.HasKey(x => x.Id);
            b.Property(x => x.MetricType).HasConversion<string>().HasMaxLength(80);
            b.Property(x => x.PeriodType).HasConversion<string>().HasMaxLength(32);
            b.HasIndex(x => new { x.TenantId, x.MetricType, x.PeriodType, x.PeriodStart }).IsUnique();
        });

        base.OnModelCreating(modelBuilder);
    }
}
