using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Reports.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Reports_20260316b : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TenantName",
                schema: "reports",
                table: "tenant_report_summaries",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TenantName",
                schema: "reports",
                table: "tenant_report_summaries");
        }
    }
}
