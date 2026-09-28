using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddDeviceProductCondition : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ProductCondition",
                schema: "devices",
                table: "devices",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "Unknown");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ProductCondition",
                schema: "devices",
                table: "devices");
        }
    }
}
