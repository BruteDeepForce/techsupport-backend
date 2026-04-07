using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.src.Modules.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Operation_20260407_2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CustomerName",
                schema: "operations",
                table: "tickets",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomerName",
                schema: "operations",
                table: "tickets");
        }
    }
}
