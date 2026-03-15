using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Reports.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianReports : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "reports");

            migrationBuilder.CreateTable(
                name: "branch_report_summaries",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: false),
                    TotalCustomers = table.Column<int>(type: "integer", nullable: false),
                    TotalOperations = table.Column<int>(type: "integer", nullable: false),
                    CompletedOperations = table.Column<int>(type: "integer", nullable: false),
                    FailedOperations = table.Column<int>(type: "integer", nullable: false),
                    DeliveredOperations = table.Column<int>(type: "integer", nullable: false),
                    OpenOperations = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_branch_report_summaries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "generated_reports",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true),
                    ContentJson = table.Column<string>(type: "text", nullable: true),
                    PeriodType = table.Column<int>(type: "integer", nullable: false),
                    PeriodDate = table.Column<DateOnly>(type: "date", nullable: true),
                    GeneratedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_generated_reports", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "processed_report_events",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EventName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    MessageId = table.Column<Guid>(type: "uuid", nullable: true),
                    CorrelationId = table.Column<Guid>(type: "uuid", nullable: true),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProcessedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_processed_report_events", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "report_metrics",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    MetricType = table.Column<int>(type: "integer", nullable: false),
                    PeriodType = table.Column<int>(type: "integer", nullable: false),
                    PeriodDate = table.Column<DateOnly>(type: "date", nullable: true),
                    Value = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_report_metrics", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "technician_report_metrics",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    TechnicianUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    MetricType = table.Column<int>(type: "integer", nullable: false),
                    PeriodType = table.Column<int>(type: "integer", nullable: false),
                    PeriodDate = table.Column<DateOnly>(type: "date", nullable: true),
                    Value = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_technician_report_metrics", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "technician_report_summaries",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    TechnicianUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    FirstName = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    LastName = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    Email = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    PhoneNumber = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: true),
                    LastProfileUpdateAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_technician_report_summaries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "tenant_report_summaries",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    TotalCustomers = table.Column<int>(type: "integer", nullable: false),
                    TotalOperations = table.Column<int>(type: "integer", nullable: false),
                    CompletedOperations = table.Column<int>(type: "integer", nullable: false),
                    FailedOperations = table.Column<int>(type: "integer", nullable: false),
                    DeliveredOperations = table.Column<int>(type: "integer", nullable: false),
                    OpenOperations = table.Column<int>(type: "integer", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tenant_report_summaries", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_branch_report_summaries_TenantId_BranchId",
                schema: "reports",
                table: "branch_report_summaries",
                columns: new[] { "TenantId", "BranchId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_generated_reports_TenantId_PeriodType_PeriodDate_GeneratedA~",
                schema: "reports",
                table: "generated_reports",
                columns: new[] { "TenantId", "PeriodType", "PeriodDate", "GeneratedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_processed_report_events_EventName_MessageId",
                schema: "reports",
                table: "processed_report_events",
                columns: new[] { "EventName", "MessageId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_report_metrics_TenantId_BranchId_MetricType_PeriodType_Peri~",
                schema: "reports",
                table: "report_metrics",
                columns: new[] { "TenantId", "BranchId", "MetricType", "PeriodType", "PeriodDate" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_technician_report_metrics_TenantId_BranchId_TechnicianUserI~",
                schema: "reports",
                table: "technician_report_metrics",
                columns: new[] { "TenantId", "BranchId", "TechnicianUserId", "MetricType", "PeriodType", "PeriodDate" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_technician_report_summaries_TenantId_BranchId_TechnicianUse~",
                schema: "reports",
                table: "technician_report_summaries",
                columns: new[] { "TenantId", "BranchId", "TechnicianUserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_technician_report_summaries_TenantId_TechnicianUserId",
                schema: "reports",
                table: "technician_report_summaries",
                columns: new[] { "TenantId", "TechnicianUserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tenant_report_summaries_TenantId",
                schema: "reports",
                table: "tenant_report_summaries",
                column: "TenantId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "branch_report_summaries",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "generated_reports",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "processed_report_events",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "report_metrics",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "technician_report_metrics",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "technician_report_summaries",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "tenant_report_summaries",
                schema: "reports");
        }
    }
}
