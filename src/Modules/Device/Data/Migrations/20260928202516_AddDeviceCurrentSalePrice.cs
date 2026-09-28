using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddDeviceCurrentSalePrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "CurrentSalePrice",
                schema: "devices",
                table: "devices",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrentSalePrice",
                schema: "devices",
                table: "devices");
        }
    }
}
