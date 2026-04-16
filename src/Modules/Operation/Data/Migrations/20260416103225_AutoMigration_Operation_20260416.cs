using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Operation_20260416 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CustomerFullName",
                schema: "operations",
                table: "operations",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TechnicianFullName",
                schema: "operations",
                table: "operations",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomerFullName",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "TechnicianFullName",
                schema: "operations",
                table: "operations");
        }
    }
}
