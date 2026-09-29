using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Reports.Data.Migrations
{
    /// <inheritdoc />
    public partial class ReportsInitialRefactor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "reports");

            migrationBuilder.CreateTable(
                name: "tenant_report_metrics",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    MetricType = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    PeriodType = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    PeriodStart = table.Column<DateOnly>(type: "date", nullable: false),
                    Value = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tenant_report_metrics", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "tenant_report_summaries",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
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
                name: "IX_tenant_report_metrics_TenantId_MetricType_PeriodType_Period~",
                schema: "reports",
                table: "tenant_report_metrics",
                columns: new[] { "TenantId", "MetricType", "PeriodType", "PeriodStart" },
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
                name: "tenant_report_metrics",
                schema: "reports");

            migrationBuilder.DropTable(
                name: "tenant_report_summaries",
                schema: "reports");
        }
    }
}
