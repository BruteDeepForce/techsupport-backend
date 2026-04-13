using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.src.Modules.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateTechnicianTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OperationType",
                schema: "technicians",
                table: "technician_operations",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OperationType",
                schema: "technicians",
                table: "technician_operations");
        }
    }
}
