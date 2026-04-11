using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Technician_20260409 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PictureUrl",
                schema: "technicians",
                table: "technicians",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PictureUrl",
                schema: "technicians",
                table: "technicians");
        }
    }
}
