using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Reports.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Reports_20260316 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FirstName",
                schema: "reports",
                table: "technician_report_summaries");

            migrationBuilder.RenameColumn(
                name: "LastName",
                schema: "reports",
                table: "technician_report_summaries",
                newName: "Name");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Name",
                schema: "reports",
                table: "technician_report_summaries",
                newName: "LastName");

            migrationBuilder.AddColumn<string>(
                name: "FirstName",
                schema: "reports",
                table: "technician_report_summaries",
                type: "character varying(128)",
                maxLength: 128,
                nullable: false,
                defaultValue: "");
        }
    }
}
